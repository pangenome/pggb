#!/usr/bin/python

import argparse

# Create the parser and add arguments
parser = argparse.ArgumentParser(
    description="It detects communities by applying the Leiden algorithm (Trag et al., 2018).",
    epilog='Author: Andrea Guarracino (https://github.com/AndreaGuarracino)'
)
parser.add_argument('-e', '--edge-list', dest='edge_list', help="edge list representing the pairs of sequences mapped in the network", required=True)
parser.add_argument('-w', '--edge-weights', dest='edge_weights', help="list of edge weights", required=True)
parser.add_argument('-n', '--vertice-names', dest='vertice_names', help="'id to sequence name' map", required=True)
parser.add_argument('--output-prefix', dest='output_prefix', default="", help="prefix to add to the output filenames")
parser.add_argument('--accurate-detection', dest='accurate', default=False, action='store_true', help="accurate community detection (slower)")
parser.add_argument('--plot', dest='plot', default=False, action='store_true', help="plot the network, coloring by community and labeling with contig/scaffold names (it assumes PanSN naming)")

# Parse and print the results
args = parser.parse_args()


import igraph as ig

# Read weights
weight_list = [float(x) for x in open(args.edge_weights).read().strip().split('\n')]

# Read the edge list and initialize the network
g = ig.read( filename=args.edge_list, format='edgelist', directed=False)

# Detect the communities
partition = g.community_leiden(
    objective_function='modularity',
    n_iterations=120 if args.accurate else 60, # -1 would indicate to iterate until convergence
    weights=weight_list
)

# Slower implementation
# import leidenalg as la
# partition = la.find_partition(
#     g,
#     la.ModularityVertexPartition,
#     n_iterations=-1 if args.accurate else 30, # -1 indicates to iterate until convergence
#     weights=weight_list,
#     seed=42
# )

print(f'Detected {len(partition)} communities.')

# Write the communities
id_2_name_dict = {}
with open(args.vertice_names) as f:
    for line in f:
        id, name = line.strip().split(' ')

        id_2_name_dict[int(id)] = name

output_prefix = args.output_prefix if args.output_prefix else args.edge_weights

for id_community, id_members in enumerate(partition):
    with open(f'{output_prefix}.community.{id_community}.txt', 'w') as fw:
        for id in id_members:
            fw.write(f'{id_2_name_dict[id]}\n')

# Write the plot
if args.plot:
    print('Plotting on PDF')

    # Take contig names (it assumes PanSN naming)
    name_list = [x.split(' ')[-1].split('#')[-1] for x in id_2_name_dict.values()]

    # To scale between ~0 and 5.0
    max_weight=max(weight_list) / 5.0

    ig.plot(
        partition,
        target = f'{output_prefix}.communities.pdf',
        vertex_size=50,
        #vertex_color=['blue', 'red', 'green', 'yellow'],
        vertex_label=name_list,
        vertex_label_size=20,
        #vertex_label_color='black',
        edge_width=[x/max_weight for x in weight_list],
        #edge_color=['black', 'grey'],
        bbox=(2000, 2000),
        margin=100
    )
