extends Node2D

# This is used to indicate which sprite(s) will be visible
# for a particular dialog line.
enum Actor {
    Player,
    Enemy1,
    Bear,
    Deer,
    Moose,
    Kangaroo
}

class DialogLine:
    var left_text = null;
    var right_text = null;
    var left_actor = null;
    var right_actor = null;

func line(the_left_actor = null, the_left_text = null, 
          the_right_actor = null, the_right_text = null):
    var the_line = DialogLine.new()
    the_line.left_actor = the_left_actor
    the_line.left_text = the_left_text
    the_line.right_actor = the_right_actor
    the_line.right_text = the_right_text
    return the_line
    
# Each item in this array is an array of DialogLine objects,
# and each of those will be shown in sequence.
var all_narratives : Array    

var current_narrative = -1
var current_line = 0

# Seconds between auto-changing lines.
var line_delay = 10
# Seconds since the last auto-change.
var current_delay = 0 

func _ready():
    # Create the narrative lists.
    
    # First set: Introduce the game.
    var narrative = []
    narrative.append(line(null, null, Actor.Enemy1, "Ah, my first quest. Level 2, here I come!"))
    narrative.append(line(Actor.Player, "Oh, great, another adventurer.", null, null))
    
    all_narratives.append(narrative)

# Show the next set of narrative texts.
# The index here refers to the literal
# array index, but it also indicates the
# level which will be played next.
func show_narrative(index: int):
    current_narrative = index
    current_line = 0
    # Bit of a hack to ensure the first line is instantly shown.
    current_delay = line_delay
    
func _process(delta):
    current_delay += delta
    
    # Don't even look unless the proper delay has passed.
    if current_delay > line_delay:
        current_delay = 0
    
        if current_narrative >= 0 and current_narrative < all_narratives.size():
            var lines = all_narratives[current_narrative]
            if current_line >= 0 and current_line < lines.size():
                self.visible = true
                
                # This is for auto-complete hints.
                var narrative : DialogLine
                narrative = lines[current_line]
                
                # Fill in text.
                if narrative.left_text == null:
                    $LeftText.text = ""
                else:
                    $LeftText.bbcode_text = narrative.left_text
                    
                if narrative.right_text == null:
                    $RightText.text = ""
                else:
                    $RightText.bbcode_text = "[right]" + narrative.right_text + "[/right]"
                
                # Show (only the correct) actors.
                hide_all_actors()
                
                if narrative.left_actor == Actor.Player:
                    $PlayerLeft.visible = true
                elif narrative.left_actor == Actor.Bear:
                    $Allies/BearLeft.visible = true
                elif narrative.left_actor == Actor.Moose:
                    $Allies/MooseLeft.visible = true
                elif narrative.left_actor == Actor.Deer:
                    $Allies/DeerLeft.visible = true
                
                if narrative.right_actor == Actor.Bear:
                    $Allies/BearRight.visible = true
                elif narrative.right_actor == Actor.Moose:
                    $Allies/MooseRight.visible = true
                elif narrative.right_actor == Actor.Deer:
                    $Allies/DeerRight.visible = true
                elif narrative.right_actor == Actor.Enemy1:
                    $Enemies/Enemy1Right.visible = true
                
                # Increment so that we progress through the list.
                current_line += 1
            
            else: # If we have a valid narrative but an invalid line, stop.
                current_narrative = -1
                current_line = 0
                self.visible = false
    

func hide_all_actors():
    $PlayerLeft.visible = false
    $Allies/BearLeft.visible = false
    $Allies/MooseLeft.visible = false
    $Allies/DeerLeft.visible = false
    $Allies/BearRight.visible = false
    $Allies/MooseRight.visible = false
    $Allies/DeerRight.visible = false
    $Enemies/Enemy1Right.visible = false
    
func showing_narrative():
    return current_narrative >= 0 and current_narrative < all_narratives.size()
