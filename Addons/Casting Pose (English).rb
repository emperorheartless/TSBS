#==============================================================================
# TSBS Addon - Casting Pose
# Version : 1.0
# Language : English
# Requires : Theolized Sideview Battle System
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Contact :
#------------------------------------------------------------------------------
# *> http://www.rpgmakerid.com
# *> http://www.rpgmakervxace.net
# *> http://theolized.blogspot.com
#==============================================================================
($imported ||= {})[:TSBS_CastPose] = true
#==============================================================================
# Change Logs:
# -----------------------------------------------------------------------------
# 2013.08.21 - Finished script
#==============================================================================
=begin
  
  ===================
  || Introduction ||
  -------------------
  This TSBS addon will make a sprite perform casting pose after you give them
  a command. Similar with Breath of Fire 4. Best used in default turn rules.
  Not in Active time battle, Free turn battle, or Charge turn battle.
  
  =================
  || How to use ||
  -----------------
  Put this script below TSBS implementation
  To setup casting pose, simply put this following tag in skill / item notebox
  
  \castpose : Action_Key
  
  ===================
  || Terms of use ||
  -------------------
  Credit me, TheoAllen. You are free to edit this script by your own. As long
  as you don't claim it yours. For commercial purpose, don't forget to give me
  a free copy of the game.
  
=end
#==============================================================================
# Configuration
#==============================================================================
module TSBS
  
  Default_SkillCast = "" # Default casting pose for Skill
  Default_ItemCast  = "" # Default casting pose for Item use
  PrepWait = 60 # Frame wait before turn start
  
  # Regex for notetag check. Do not change if you don't understand
  CastPose = /\\castpose\s*:\s*(.+)/i
  
end
#==============================================================================
# End of configuration. Do not edit pass this line!
#==============================================================================
class RPG::UsableItem
  attr_accessor :cast_pose
  
  alias addon_cast_load_tsbs load_tsbs
  def load_tsbs
    addon_cast_load_tsbs
    @cast_pose = TSBS::Default_SkillCast if is_a?(RPG::Skill)
    @cast_pose = TSBS::Default_SkillCast if is_a?(RPG::Item)
    note.split(/[\r\n]+/).each do |line|
      @cast_pose = $1.to_s if line =~ TSBS::CastPose
    end
  end
  
end

class Game_Battler
  attr_reader :cast_pose
  
  alias tsbs_castpose_clear clear_tsbs
  def clear_tsbs
    tsbs_castpose_clear
    @cast_pose = ""
  end
  
  def idle
    return data_battler.dead_key if dead? && actor?
    return @cast_pose if !@cast_pose.empty?
    return state_sequence if state_sequence
    return data_battler.critical_key if critical? && 
      !data_battler.critical_key.empty?
    return data_battler.idle_key
  end
  
  def action_set?
    !@actions.empty? && @actions[0].target_index > -1 && 
      !@actions[0].item.cast_pose.empty?
  end
    
  def cast_pose=(key)
    if @cast_pose != key
      @cast_pose = key
      self.battle_phase = :idle
    end
  end
  
end

class Scene_Battle
  
  alias tsbs_castpose_command_attack command_attack
  def command_attack
    tsbs_castpose_command_attack
    @used_item = $data_skills[BattleManager.actor.attack_skill_id]
  end
  
  alias tsbs_castpose_on_skill_ok on_skill_ok
  def on_skill_ok
    tsbs_castpose_on_skill_ok
    @used_item = @skill
  end
  
  alias tsbs_castpose_on_item_ok on_item_ok
  def on_item_ok
    tsbs_castpose_on_item_ok
    @used_item = @item
  end
  
  alias tsbs_castpose_on_enemy_ok on_enemy_ok
  def on_enemy_ok
    actor = BattleManager.actor
    actor.cast_pose = @used_item.cast_pose if @used_item && 
      actor.cast_pose.empty?
    tsbs_castpose_on_enemy_ok
  end
  
  alias tsbs_castpose_show_action_sequences show_action_sequences
  def show_action_sequences(targets, item)
    @subject.cast_pose = ""
    tsbs_castpose_show_action_sequences(targets, item)
  end
  
  alias tsbs_castpose_turn_start turn_start
  def turn_start
    tsbs_castpose_turn_start
    wait(TSBS::PrepWait)
  end
  
end
