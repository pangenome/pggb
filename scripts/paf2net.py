#!/usr/bin/python

import argparse

# Create the parser and add arguments
parser = argparse.ArgumentParser(
    description="It projects wfmash's PAF mappings (the implied overlap and containment graph) into an edge list, a list of edge weights, and an 'id to sequence name' map.",
    epilog='Author: Andrea Guarracino (https://github.com/AndreaGuarracino)'
)
parser.add_argument('-p', '--paf', dest='paf', help="wfmash's PAF file with the mappings (generated with wfmash -m)", required=True)

# Parse and print the results
args = parser.parse_args()

# Prepare the `sequence name to id` map
id = 0
name_2_id_dict = {}
with open(args.paf) as f:
    for line in f:
        name1, _, _, _, _, name2, _, _, _, _, align_len, _, est_identity = line.strip().split('\t')[:13]

        for nameX in [name1, name2]:
            if nameX not in name_2_id_dict:
                name_2_id_dict[nameX] = str(id)
                id += 1

# Write files
fw_edges = open(args.paf + '.edges.list.txt', 'w')
fw_weights = open(args.paf + '.edges.weights.txt', 'w')

with open(args.paf) as f:
    for line in f:
        name1, _, _, _, _, name2, _, _, _, _, align_len, _, est_identity = line.strip().split('\t')[:13]
        align_len = int(align_len)
        # wfmash -m --> est_identity contains 'id:f:xx.xxxx', that is the estimated identity
        # wfmash    --> est_identity contains 'id:f:xx.xxxx', that is the gap-compressed identity
        est_identity = float(est_identity.split(':')[-1])

        # Write edges in the form of 'id1 id2'
        fw_edges.write(' '.join([name_2_id_dict[name1], name_2_id_dict[name2]]) + '\n')

        # Long and high estimated identity mappings have greater weight
        fw_weights.write(str(align_len * est_identity / 100.0) + '\n')

fw_edges.close()
fw_weights.close()

# Write the 'id to sequence name' map
with open(args.paf + '.vertices.id2name.txt', 'w') as fw:
    for name, id in name_2_id_dict.items():
        fw.write(' '.join([id, name]) + '\n')
