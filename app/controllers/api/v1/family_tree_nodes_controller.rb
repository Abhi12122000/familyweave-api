# frozen_string_literal: true

module Api
  module V1
    class FamilyTreeNodesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_family_tree
      before_action :authorize_user_for_tree!

      # POST /api/v1/family_trees/:family_tree_id/nodes
      def create
        @family_tree_node = @family_tree.family_tree_nodes.build(family_tree_node_params)
        
        # If linked_user_id is provided, try to associate with an existing user
        # For now, we assume client sends linked_user_id if they want to link.
        # More complex logic for finding/inviting users can be added later.

        if @family_tree_node.save
          render json: FamilyTreeNodeSerializer.new(@family_tree_node).serializable_hash, status: :created
        else
          render json: { errors: @family_tree_node.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_family_tree
        @family_tree = FamilyTree.find_by(id: params[:family_tree_id])
        unless @family_tree
          render json: { error: 'FamilyTree not found.' }, status: :not_found
          return # Ensure no further action is taken if tree not found
        end
      end

      def authorize_user_for_tree!
        # Ensure set_family_tree has run and @family_tree is present
        return if @family_tree.nil? 

        # Only the owner of the family tree can add nodes for now
        unless @family_tree.owner == current_api_v1_user
          render json: { error: 'You are not authorized to modify this family tree.' }, status: :forbidden
        end
      end

      def family_tree_node_params
        params.require(:family_tree_node).permit(
          :first_name, :last_name, :gender, :date_of_birth, :date_of_death,
          :is_placeholder, :linked_user_id
        )
      end
    end
  end
end 