# -*- coding: utf-8 -*-
"""NoC.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/177l6Rt6fEHfLy8vX5eGLjLMwoyQ6IdNM
"""

import matplotlib.pyplot as plt
import numpy as np
import networkx as nx
import pandas as pd

# 2D network create
N=4
G = nx.grid_2d_graph(N,N)
labels=dict(((i,j),i + (N-1-j)*N) for i, j in G.nodes())
# node id
nx.relabel_nodes(G,labels,False) 
inds=labels.keys()
vals=labels.values()
grid_pos=dict(zip(vals,inds)) #Format: {node ID:(i,j)}
plt.figure()
# initial value
df = pd.DataFrame({'value':[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]})
kf = pd.DataFrame({'trojan':[3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,3]})
# read busy from file
f = open("output_results.txt", 'r')
nums = f.readlines()
nums = [int(i) for i in nums]

# update value
df['value'] = nums

# The basic information 
print("Trojan in node 1100(12)")
print("Dark Bule: Packet from 0100(4) to 1110(14), packet dropped in node 13")
# print("Sky Bule: Packet from 1101(13) to 0110(6)")
# draw the network
# nx.draw(G,pos=grid_pos,with_labels=True,edge_color=df['value'],width=5.0,node_size=800)
nx.draw(G,pos=grid_pos,with_labels=True,edge_color=df['value'],width=5.0,node_size=800,node_color=kf['trojan'])
plt.show()