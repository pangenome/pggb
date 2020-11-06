#!/usr/bin/env nextflow

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

makeBaseName = { f -> """\
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
  set f, file(fasta) from fasta

  output:
  set f, file(fasta), file("${f}.paf") into alignments

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
  set f, file(fasta), file(alignment) from alignments

  output:
  set f, file("${f}.seqwish.gfa") into graphs

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
  set f, file(graph) from graphs

  output:
  set f, file("${f}.smooth.gfa") into smoothed

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
  set f, file(graph) from smoothed

  output:
  set f, file("${f}.smooth.og") into converted

  """
  odgi build -g $graph -o ${f}.smooth.og
  """
}

(toViz, toLayout) = converted.into(2)

process odgiViz {
  input:
  set f, file(graph) from toViz

  output:
  set f, file("${f}.smooth.og.viz.png") into viz

  """
  odgi viz \
    -i $graph \
    -o ${f}.smooth.og.viz.png \
    -x 1500 -y 500 -P 5
  """
}

process odgiChop {
  input:
  set f, file(graph) from toLayout

  output:
  set f, file("${f}.smooth.chop.og") into chopped

  """
  odgi chop -i $graph -c 100 -o ${f}.smooth.chop.og
  """
}

process odgiLayout {
  input:
  set f, file(graph) from chopped

  output:
  set f, file(graph), file("${f}.smooth.chop.og.lay") into layout

  """
  odgi layout \
    -i $graph \
    -o ${f}.smooth.chop.og.lay \
    -t ${task.cpus} -P
  """
}

process odgiDraw {
  input:
  set f, file(graph), file(layoutGraph) from layout

  output:
  set f, file("${f}.smooth.chop.og.lay.png") into chopViz

  """
  odgi draw \
    -i $graph \
    -c $layoutGraph \
    -p ${f}.smooth.chop.og.lay.png \
    -H 1000 -t ${task.cpus}
  """
}
