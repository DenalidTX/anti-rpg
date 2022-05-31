extends Node

var PathNodeType = load("res://util/PathNode.gd")

# Unfortunately, this is a manual graph creation. I don't have a good way
# to create a directed cyclic graph otherwise.
func create_default_graph():
    # Initialize all nodes. These are new so that we can create
    # different (modified) graphs without affecting existing graphs.
    # It's small enough that I'm not concerned about performance (yet).
    var node_start = PathNodeType.new(get_node("Path_Start").position) # All enemies start here.
    var node_right = PathNodeType.new(get_node("Path_Right").position)
    var node_right_top = PathNodeType.new(get_node("Path_RightTop").position)
    var node_top_right = PathNodeType.new(get_node("Path_TopRight").position)
    var node_top = PathNodeType.new(get_node("Path_Top").position)
    var node_top_left = PathNodeType.new(get_node("Path_TopLeft").position)
    var node_fork = PathNodeType.new(get_node("Path_Fork").position)
    var node_campsite_top_right = PathNodeType.new(get_node("Path_CampsiteTopRight").position)
    var node_campsite_top_left = PathNodeType.new(get_node("Path_CampsiteTopLeft").position)
    var node_campsite_bottom_right = PathNodeType.new(get_node("Path_CampsiteBottomRight").position)
    var node_campsite_bottom_left = PathNodeType.new(get_node("Path_CampsiteBottomLeft").position)
    var node_left = PathNodeType.new(get_node("Path_Left").position)
    var node_bottom = PathNodeType.new(get_node("Path_Bottom").position)
    var node_clearing_top_right = PathNodeType.new(get_node("Path_ClearingTopRight").position)
    var node_clearing_top = PathNodeType.new(get_node("Path_ClearingTop").position)
    var node_clearing_left = PathNodeType.new(get_node("Path_ClearingLeft").position)
    var node_clearing_center = PathNodeType.new(get_node("Path_ClearingCenter").position)
    var node_end_left = PathNodeType.new(get_node("Path_EndLeft").position) # Enemies can end here.
    var node_end_bottom = PathNodeType.new(get_node("Path_EndBottom").position) # Enemies can end here.
    
    # Enemies always move here first.
    node_start.children.append(node_right)
    node_right.children.append(node_fork)
    
    # Top Right Path
    node_fork.children.append(node_right_top)
    #node_right.children.append(node_right_top)
    node_right_top.children.append(node_top_right)
    node_top_right.children.append(node_top)
    node_top.children.append(node_left)
    
    # Several paths go through the fork node. That's why it's a fork.
    # node_right.children.append(node_fork)
    
    # Top Path
    node_fork.children.append(node_top)
    node_top.children.append(node_top_left)
    node_top_left.children.append(node_left)
    
    # Middle Path
    node_fork.children.append(node_clearing_top_right)
    node_clearing_top_right.children.append(node_clearing_top)
    node_clearing_top.children.append(node_left)
    
    # Clearing Path
    # This branches from the middle path and ultimately goes to the bottom exit.
    node_clearing_top_right.children.append(node_clearing_left)
    node_clearing_left.children.append(node_bottom)
    
    # Bottom Path
    node_fork.children.append(node_campsite_top_left)
    node_campsite_top_left.children.append(node_clearing_center)
    node_clearing_center.children.append(node_bottom)
    
    # Campsite Path
    node_fork.children.append(node_campsite_top_right)
    #node_right.children.append(node_campsite_top_right)
    node_campsite_top_right.children.append(node_campsite_bottom_right)
    node_campsite_bottom_right.children.append(node_campsite_bottom_left)
    node_campsite_bottom_left.children.append(node_bottom)
    
    # Enemies always move offscreen from these two.
    node_left.children.append(node_end_left)
    node_bottom.children.append(node_end_bottom)
    
    return node_start
