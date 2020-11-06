#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.input_fasta="${baseDir}/**.fa.gz"
params.map_pct_id=false
params.align_pct_id=false
params.n_secondary=false
params.segment_length=false
params.mash_kmer=16
params.min_match_length=8
params.max_block_weight=10000
params.max_path_jump=5000
params.min_subpath=0
params.max_edge_jump=5000
params.max_poa_length=10000
params.do_viz=false
params.do_layout=false

def makeBaseName = { f -> """\
${f.getSimpleName()}.pggb-\
s${params.segment_length}-\
p${params.map_pct_id}-\
n${params.n_secondary}-\
a${params.align_pct_id}-\
K${params.mash_kmer}-\
k${params.min_match_length}-\
w${params.max_block_weight}-\
j${params.max_path_jump}-\
W${params.min_subpath}-\
e${params.max_edge_jump}\
""" }

fasta = Channel.fromPath("${params.input_fasta}").map { f -> tuple(makeBaseName(f), f) }

process edyeet {
  input:
  tuple val(f), file(fasta)

  output:
  tuple val(f), file(fasta), file("${f}.paf")

  """
  edyeet -X \
     -s ${params.segment_length} \
     -p ${params.map_pct_id} \
     -n ${params.n_secondary} \
     -a ${params.align_pct_id} \
     -k ${params.mash_kmer} \
     -t ${task.cpus} \
     $fasta $fasta \
     >${f}.paf 
  """
}


process seqwish {
  input:
  tuple val(f), file(fasta), file(alignment)

  output:
  tuple val(f), file("${f}.seqwish.gfa")

  """
  seqwish \
    -t ${task.cpus} \
    -s $fasta \
    -p $alignment \
    -k ${params.min_match_length} \
    -g ${f}.seqwish.gfa -P
  """
}

process smoothxg {
  input:
  tuple val(f), file(graph)

  output:
  tuple val(f), file("${f}.smooth.gfa")

  """
  smoothxg \
    -t ${task.cpus} \
    -g $graph \
    -w ${params.max_block_weight} \
    -j ${params.max_path_jump} \
    -e ${params.max_edge_jump} \
    -l ${params.max_poa_length} \
    -o ${f}.smooth.gfa \
    -m ${f}.smooth.maf \
    -s ${f}.consensus \
    -a \
    -C 5000 \
  """
}

process odgiBuild {
  input:
  tuple val(f), file(graph)

  output:
  tuple val(f), file("${f}.smooth.og")

  """
  odgi build -g $graph -o ${f}.smooth.og
  """
}

process odgiViz {
  input:
  tuple val(f), file(graph)

  output:
  tuple val(f), file("${f}.smooth.og.viz.png")

  """
  odgi viz \
    -i $graph \
    -o ${f}.smooth.og.viz.png \
    -x 1500 -y 500 -P 5
  """
}

process odgiChop {
  input:
  tuple val(f), file(graph)

  output:
  tuple val(f), file("${f}.smooth.chop.og")

  """
  odgi chop -i $graph -c 100 -o ${f}.smooth.chop.og
  """
}

process odgiLayout {
  input:
  tuple val(f), file(graph)

  output:
  tuple val(f), file(graph), file("${f}.smooth.chop.og.lay")

  """
  odgi layout \
    -i $graph \
    -o ${f}.smooth.chop.og.lay \
    -t ${task.cpus} -P
  """
}

process odgiDraw {
  input:
  tuple val(f), file(graph), file(layoutGraph)

  output:
  tuple val(f), file("${f}.smooth.chop.og.lay.png")

  """
  odgi draw \
    -i $graph \
    -c $layoutGraph \
    -p ${f}.smooth.chop.og.lay.png \
    -H 1000 -t ${task.cpus}
  """
}


workflow {
    edyeet(fasta)
    seqwish(edyeet.out)
    smoothxg(seqwish.out)
    odgiBuild(smoothxg.out)
    odgiViz(odgiBuild.out)
    odgiChop(odgiBuild.out)
    odgiLayout(odgiChop.out)
    odgiDraw(odgiLayout.out)
}