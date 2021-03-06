#!/usr/bin/env ruby
#
# foaf pathfinder (cargo cult edition) 
# $Id: pathfinder.rb,v 1.4 2002-08-05 14:09:15 danbri Exp $ danbri@rdfweb.org
#
# This is a Ruby transliteration of a collection of Java classes 
# originally by Damian Steer and Libby Miller.
# Damian did the clever algorithm stuff.
#
# Mindlessly-transliterated Ruby version 
# and associated bugs/glitches by Dan.
#
# see http://rdfweb.org/people/damian/2002/02/foafnation/
# http://swordfish.rdfweb.org/people/libby/rdfweb/paths/
#
#  what is this?
#
#  pathfinder will find paths through a graph of edges and nodes.
#
#  the data is loaded from an RDF query service. Sample uses include
#  'codepiction paths', ie. connections between people where photos   
#  are the edges; also FOAFCorp paths, with companies as nodes, and 
#  their board-members as members. Other apps might include the usual
#  movies, musicians, mathematicians, or combinations of all these.
#
#  todo: improve configurability, API; database storage of paths.
#
#
#
# Copyright 2002 Dan Brickley, Libby Miller, Damian Steer.
#
# 
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

require 'getoptlong'

#
# 
# classes: TElement, TEdge, TNode, TGraph
#
# todo: translate BuildPath.java machinery for storing paths in RDBMS
#   -- we don't yet store the paths in an SQL db, just dump the graph to rdf
#   -- maybe we could use a DBM or BerkeleyDB to store paths? SQL seems overkill


#################################################################
######################### TElement

# This class represents a simple tree element. It is only used for
# the 'shortest paths' routine as a simple way to store paths in a
# (hopefully) efficient manner.

class TElement 
  attr_accessor :parent, :node, :edge
  def initialize (node, parent, edge = nil) 
    @node = node
    @parent = parent
    @edge = edge
  end
  def to_s
    return @node.to_s
  end
end


###########################################################
######################### TEdge

class TEdge

    attr_accessor :node1, :node2, :labels, :hash

    def initialize(node1, node2, label)
	@node1 = node1
	@node2 = node2
	@labels = []
	@labels.push(label)
	@node1.addEdge self
	@node2.addEdge self
    end

    def to_s
        
    	return @labels.join(" ").to_s

    end

    def addLabel (label)
	@labels.push(label)
    end

    def  getLabel()
	if (@labels.size() == 1)
		return @labels[0].to_s
	else
		i = 0
		return  @labels[random(labels.size)].to_s
	end
    end

    def getOtherNode(node)    
      if node == @node1  # todo: is this correct? or diff notion of equality needed?
        return @node2
      else
        return @node1
      end

    end 
end


###########################################################
######################### TNode

class TNode

  attr_accessor :edges, :text, :name, :hash, :visited
  # todo: strip out java-esque accessors

  def initialize(text='nothing')
    @text = text
    @edges = []
    @name="noone"
    @hash = 0 #int
    @visited= false #boolean
  end
  
  def notVisited
    return !@visited #boolean
  end

  def addEdge edge
    @edges.push edge
  end

  def getEdges
    return @edges # []
  end

  def to_s
    return @text
  end    

  def sameNode (obj)
    ## this was .equals() in java...
    ## todo:Should ret false unless obj is a TNode
    ## hmm, is this how we do string eq testing?
    if obj.to_s =~ self.to_s # todo: inefficient?
      # puts "node compared equal "+self.to_s
      return true
    else 
      # puts "node '"+obj.to_s+"' compared not equal "+self.to_s
      return false
    end

  end 


  # Note: we add 'from' here to reduce the cloning of Vectors
  # ret void; sends Vector, Vector, tEdge, int
  def getPaths (paths, pathToMe, from, ttl)
    if (pathToMe.contains(self)) 
      return
    end

    ttl = ttl-1 # ?
    if (ttl == 0) 
      return # Kill it off if the path is too long
    end

    pathIncludingMe = pathToMe.copy #or clone() per java orig?
	
    # if this is the start node 'from' will be nil
    if (from != nil) 
      pathIncludingMe.push(from)
    end
    pathIncludingMe.addElement(self) 	# new path with me in it
    paths.add(pathIncludingMe) 		# add it to the other paths

    edges.each do |e| 
      edge = e.pop
      if (edge == from) 
        continue 
      end

      otherEnd = edge.getOtherNode(self);

      # add paths for edges
      otherEnd.getPaths(paths, pathIncludingMe, edge, ttl);
      end
  end
    
  def pathsFromWithTTL(ttl)
    # takes vector, returns int
    paths = []
    pathToMe = []
    self.getPaths(paths, pathToMe, nil, ttl)
	
    # We aren't interested in the first path found
    # (it is just this node)
    paths.removeElementAt(0) # todo! Odd, this hasn't caused a problem yet. junk?
    return paths
  end
end

###########################################################
######################### TGraph

require 'basicrdf'

class TGraph
  attr_accessor :edges, :nodes, :nodeLookup, :edgeLookup, :complex

  def initialize 
    @edges = []
    @nodes = []
    @nodeLookup = {}
    @edgeLookup = {}
    @complex = true
  end

  def addPath( node1, node2, edgeLabel)
    addPathWithName(node1,node2,edgeLabel, nil, nil)
  end

 def addPathWithName(node1, node2, edgeLabel, name1, name2)

    raise "addPathWithName called with nil node refs" if (node1==nil or node2==nil)

   node1.downcase!
   node2.downcase!

   if (node1 == node2) ## string names for nodes, how to test string eq?
     return
   end

    edgeObj = @edgeLookup[node1 + node2] #todo: + ???
    if (edgeObj == nil) 
      edgeObj = @edgeLookup[node2 + node1]
    end

     nodeObj1 = @nodeLookup[node1]
     nodeObj2 = @nodeLookup[node2]

     if (nodeObj1 == nil)
       nodeObj1 = TNode.new node1
       if(name1!=nil)
   	 nodeObj1.name=name1
       end
       @nodes.push(nodeObj1)
       @nodeLookup[node1]= nodeObj1
     end

     if (nodeObj2 == nil)
       nodeObj2 = TNode.new node2
       if(name2!=nil)
         nodeObj2.name=name2
       end
       @nodes.push(nodeObj2)
       @nodeLookup[node2] = nodeObj2
     end

     if (edgeObj == nil) 
       edgeObj = TEdge.new(nodeObj1, nodeObj2, edgeLabel)
       @edges.push(edgeObj)
       @edgeLookup[node1 + node2]= edgeObj
     else
       edgeObj.addLabel(edgeLabel)
       end
    end

  def to_s
    string = "[";
    @edges.each do |edge| 
      node1 = edge.node1
      node2 = edge.node2
      string += "["+node1+","+edge+","+node2+"]"
    end
    string += "]"
    return string
  end

  def getEdges
    return @edges
  end

  def getNodes
    return @nodes
  end

# 
#  This method finds the shortest paths between a node in the graph
#  and all other (reachable) nodes. It returns a Vector of tree
#  elements. To find each path start with each element of the
#  vector, find its parent, and repeat until parent == nil. That
#  gives you all the shortest paths. Easy, huh? And hopefully fast

  def findShortestPathsFromNode(root)
  # Clear graph for search
    @nodes.each do |node|
      node.visited=false
    end

    # But (of course) we start with a node, so let's say it's been visited

    root.visited=true

    # Set up the root of the tree
    treeRoot = TElement.new(root, nil)
    # Set up parents vector (just treeRoot) and leaves (empty)
    parents = []
    parents.push treeRoot
    leaves = []
    # indicates whether to keep going
    continuing = true
    # todo: this is going to look rather different in Ruby! double-check w/ original java
    while (continuing)
      children = []
      continuing = false
      parents.each do |parent| 
        parentNode = parent.node
        # puts "Doing parent: #{parentNode} " 
        parentNode.getEdges.each do |edge|
          # puts "Doing edge(s): #{edge} " 
          childNode = edge.getOtherNode parentNode
          if childNode.notVisited
 	    childNode.visited=true 
            # puts "visited: #{childNode}"
            child = TElement.new (childNode, parent, edge)
            leaves.push child
            children.push child
            continuing = true
          end
	  parents = children
	end
      end
    end
    #puts "returning: #{leaves}"
    return leaves 
  end

  def findShortestPathsFromNodeNamed (name)
    node = @nodeLookup[name]
    if node == nil
      puts ("No node named '" + name + "'") ## todo: STDERR!
      return nil
    end
    return (findShortestPathsFromNode node)
  end

  def paths (leaves)
    pathString = ""
    leaves.each do |leaf|
      while (leaf.parent != nil)
        pathString += leaf.node + " , "
	leaf = leaf.parent
   	pathString += leaf.node + "\n"
      end
    end 
    return pathString
  end

  def pathLength leaf
    length = 1;
    while (leaf.parent != nil)
      leaf = leaf.parent
      length = length+1
    end
    return length
  end

  def averagePathLength (paths)
    length = 0
    paths.each do |p|
      length += pathLength(p)
    end
    return (length / paths.size) # floats: todo, to_float?
  end

  def buildGraph (graph)	
    require 'squish' 
    require 'dbi'
 
    # note: final , in select clause. bug in squish.rb

    query =<<EOQ;

	SELECT ?mbox1, ?mbox2, ?uri,  
	WHERE
       (foaf::depiction ?x ?img)
       (foaf::depiction ?z ?img)
       (foaf::thumbnail ?img ?uri)
       (foaf::mbox ?x ?mbox1)
       (foaf::mbox ?z ?mbox2)
	USING foaf for http://xmlns.com/foaf/0.1/

EOQ

    q = SquishQuery.new.parseFromText query
    DBI.connect ('DBI:Pg:rdfweb1','danbri','') do | dbh |
      dbh.select_all( q.toSQLQuery  ) do | row |
        puts row.inspect
        # print '.' # progressometer
        p = ResultRow.new(row)
	graph.addPath(p.mbox1, p.mbox2, p.uri)
      end 
    end
  end

  ###########################################################

  def TGraph.main(args={})
    @complex=true # verbose RDF output
    all=""
    who = args['who'] 
    who = 'mailto:danbri@w3.org' if !who
    genrdf = args['genrdf']

    graph = TGraph.new
    graph.buildGraph(graph)

     puts "# of nodes: " + graph.getNodes.size.to_s
     puts "# of edges: " + graph.getEdges.size.to_s
     puts "Nodelookup table: " 
     graph.nodeLookup.each_key do |k| 
       puts "node: #{k} "
     end 	 

     puts "\n\n\n"

     danpath = graph.findShortestPathsFromNodeNamed who
     puts "\n\nDanpaths: " 
     danpath.each do |e|
       puts "Path:\n"
       while (e.parent != nil) 
         puts " path element: "+e.to_s
         e = e.parent
       end
     end
     puts "\n\n\n"


    if genrdf  
      # see BuildPath for how we might store this graph in SQL
      # for fast retrieval

      topPerson = nil
      avLen = 0

      all += ("<?xml version=\"1.0\" ?>\n")
      all += ("<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n")
      all += (" xmlns:foaf=\"http://xmlns.com/foaf/0.1/\">\n")
      graph.edges.each do |edge|
        node1 = edge.node1
        node2 = edge.node2
        if(!@complex)
                  all += ("<!-- simple description of a codepiction --> \n")
 		  all += ("<rdf:Description rdf:about=\""+node1+"\">\n")
		  all += ("<foaf:codepiction rdf:resource=\""+node2+"\" />\n")
		  all += ("</rdf:Description>\n")
        else
                  all += ("<!-- complex description of a codepiction --> \n")
  		  all += ("<rdf:Description rdf:about=\""+node1.text+"\">\n")
		  all += ("<foaf:depiction rdf:resource=\""+edge.getLabel()+"\" />\n")
		  all += ("</rdf:Description>\n")
		  all += ("<rdf:Description rdf:about=\""+node2.text+"\">\n")
		  all += ("<foaf:depiction rdf:resource=\""+edge.getLabel()+"\" />\n")
		  all += ("</rdf:Description>\n\n\n")
        end
      end
      all += ("</rdf:RDF>")
      puts all;
    end
  
  end

end # /class TGraph


###########################################################


