#!/usr/bin/env python

import web
import json
import math
import numpy as np
import scipy as sp
import pandas as pd
import networkx as nx
import datetime

urls = ('/','root')
app = web.application(urls,globals())

class root:
 
    def __init__(self):
        self.hello = "hello world"
 
    def GET(self):
		web.header('Access-Control-Allow-Origin', '*')
		output = dict()
		getInput = web.input(start='2012-3-03 16:00:00', end='2012-3-03 21:00:00')
		start_time=pd.to_datetime(getInput.start).tz_localize('US/Eastern') - pd.DateOffset(hours=10)
		end_time=pd.to_datetime(getInput.end).tz_localize('US/Eastern') - pd.DateOffset(hours=10)
		
		output_nodes = set()
		all_schedules = pd.read_json('all_schedules.json')
		allnodes = pd.read_json('allnodes.json')
		nodes = set(allnodes.nodes)
		all_schedules['end'] = all_schedules['end'].map(lambda x: datetime.datetime.fromtimestamp(x/1000000000))
		all_schedules['start'] = all_schedules['start'].map(lambda x: datetime.datetime.fromtimestamp(x/1000000000))

		night_sched = all_schedules[(all_schedules.start >= start_time) & (all_schedules.end <= end_time)]
		on_nodes = set()
		for idx,show in night_sched.iterrows():
			on_nodes.add(show[2])
		
		off_nodes = nodes.difference(on_nodes)
		
		imported_graph = nx.read_gexf('./finished_network3.gexf')
		for i in off_nodes:
			try:
				imported_graph.remove_node(i)
			except:
				continue
		
		pr=nx.pagerank(imported_graph,alpha=0.9,weight='newweight',tol=.01, max_iter=200)
		
		output['nodes'] = [(i,v*1000000) for i,v in pr.items()]
		output['input_params'] = getInput
		return json.dumps(output)
 
if __name__ == "__main__":
        app.run()
