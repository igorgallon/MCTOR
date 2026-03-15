#!/usr/bin/env python3
"""
Plot .app application graphs with multiple layout options including an equal-spaced grid.

Usage:
  python plot_app_graph.py path.app [out.png] [layout] [ncols]

Layouts:
  grid     - place nodes on an equal-spaced rectangular grid (default when ntasks known)
  circular - circular layout (nodes equally spaced on a circle)
  spring   - spring force-directed layout (networkx.spring_layout)
  shell    - shell layout

Example:
  python plot_app_graph.py embedded_app_graphs/vopd.app vopd.png grid 4

Depends: networkx, matplotlib, numpy
Install: pip install networkx matplotlib numpy
"""
import sys
import os
import math
import networkx as nx
import matplotlib.pyplot as plt
import numpy as np


def read_app(path):
    ntasks = None
    edges = []
    with open(path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('#[ntasks]'):
                # next numeric line contains ntasks (handled below)
                continue
            if ntasks is None and line.isdigit():
                ntasks = int(line)
                continue
            if line.startswith('#[graph]'):
                continue
            parts = line.split()
            if len(parts) >= 2 and parts[0].lstrip('-').isdigit():
                src = int(parts[0]); dst = int(parts[1])
                w = float(parts[2]) if len(parts) > 2 else 1.0
                edges.append((src, dst, w))
    return ntasks, edges


def grid_positions(ntasks, ncols=None, spacing=(1.0, 1.0)):
    """Return positions dict for nodes 0..ntasks-1 placed on an equal-spaced grid."""
    if ntasks is None or ntasks <= 0:
        return {}
    if ncols is None:
        ncols = int(math.ceil(math.sqrt(ntasks)))
    ncols = max(1, int(ncols))
    nrows = int(math.ceil(ntasks / ncols))

    positions = {}
    for idx in range(ntasks):
        row = idx // ncols
        col = idx % ncols
        # flip row so node 0 is top-left visually
        x = col * spacing[0]
        y = -row * spacing[1]
        positions[idx] = np.array([x, y])
    return positions


def plot_app(path, out=None, layout='grid', ncols=None):
    ntasks, edges = read_app(path)
    G = nx.DiGraph()
    if ntasks:
        G.add_nodes_from(range(ntasks))
    else:
        # add nodes found in edges
        nodes = set()
        for s,d,w in edges:
            nodes.add(s); nodes.add(d)
        G.add_nodes_from(sorted(nodes))

    for s,d,w in edges:
        G.add_edge(s, d, weight=w)

    if layout == 'grid' and ntasks:
        pos = grid_positions(ntasks, ncols=ncols, spacing=(1.6, 1.6))
    elif layout == 'circular':
        pos = nx.circular_layout(G)
    elif layout == 'shell':
        pos = nx.shell_layout(G)
    elif layout == 'spring':
        pos = nx.spring_layout(G, seed=42)
    else:
        pos = nx.spring_layout(G, seed=42)

    plt.figure(figsize=(max(8, len(G.nodes()) * 0.5), 6))
    nx.draw_networkx_nodes(G, pos, node_size=600, node_color='lightblue')
    nx.draw_networkx_labels(G, pos, font_size=9)

    weights = nx.get_edge_attributes(G, 'weight')
    if weights:
        maxw = max(weights.values())
    else:
        maxw = 1.0
    widths = [max(0.5, (weights.get((u, v), 1.0) / maxw) * 4.0) for u, v in G.edges()]

    nx.draw_networkx_edges(G, pos, arrowstyle='->', arrowsize=12, width=widths, edge_color='gray')

    if weights:
        edge_labels = {(u, v): f"{d:.0f}" for (u, v), d in weights.items()}
        nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, font_size=8)

    plt.title(os.path.basename(path))
    plt.axis('off')
    if out:
        plt.savefig(out, dpi=200, bbox_inches='tight')
        print('Saved', out)
    plt.show()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python plot_app_graph.py path.app [out.png] [layout] [ncols]')
        sys.exit(1)
    path = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else None
    layout = sys.argv[3] if len(sys.argv) > 3 else 'grid'
    ncols = int(sys.argv[4]) if len(sys.argv) > 4 else None
    plot_app(path, out=out, layout=layout, ncols=ncols)
