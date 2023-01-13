#!/usr/bin/python

import argparse

# Create the parser and add arguments
parser = argparse.ArgumentParser(
    description="It projects mash's distances into an edge list, a list of edge weights, and an 'id to sequence name' map.",
    epilog='Author: Andrea Guarracino (https://github.com/AndreaGuarracino)'
)
parser.add_argument('-m', '--mash', dest='mash', help="mash's distances file", required=True)
parser.add_argument('-d', '--max-distance', dest='dist', help="ignores sequence pairs with estimated distance greater than DIST", required=False, type=float, default=0.4)

# Parse and print the results
args = parser.parse_args()

# Prepare the `sequence name to id` map
id = 0
name_2_id_dict = {}
with open(args.mash) as f:
    for line in f:
        name1, name2, mash_distance, _, ratio = line.strip().split('\t')

        if name1 != name2:
            for nameX in [name1, name2]:
                if nameX not in name_2_id_dict:
                    name_2_id_dict[nameX] = str(id)
                    id += 1

# Write files
fw_edges = open(args.mash + '.edges.list.txt', 'w')
fw_weights = open(args.mash + '.edges.weights.txt', 'w')

with open(args.mash) as f:
    for line in f:
        name1, name2, mash_distance, _, ratio = line.strip().split('\t')

        if name1 != name2:
            mash_distance = float(mash_distance)
            if mash_distance <= args.dist:
                # Write edges in the form of 'id1 id2'
                fw_edges.write(' '.join([name_2_id_dict[name1], name_2_id_dict[name2]]) + '\n')

                # More shared hashes have more weight
                shared_hashes = int(ratio.split('/')[0])
                fw_weights.write(str(shared_hashes) + '\n')

fw_edges.close()
fw_weights.close()

# Write the 'id to sequence name' map
with open(args.mash + '.vertices.id2name.txt', 'w') as fw:
    for name, id in name_2_id_dict.items():
        fw.write(' '.join([id, name]) + '\n')
