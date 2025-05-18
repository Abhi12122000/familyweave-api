# frozen_string_literal: true

module Api
  module V1
    class FamilyTreesController < ApplicationController
      before_action :authenticate_api_v1_user!

      # POST /api/v1/family_trees
      def create
        @family_tree = current_api_v1_user.build_owned_family_tree(family_tree_params)
        if @family_tree.save
          render json: FamilyTreeSerializer.new(@family_tree).serializable_hash, status: :created
        else
          render json: { errors: @family_tree.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/family_trees/mine
      def mine
        @family_tree = current_api_v1_user.owned_family_tree
        if @family_tree
          render json: FamilyTreeSerializer.new(@family_tree).serializable_hash, status: :ok
        else
          render json: { message: 'No family tree found for the current user.' }, status: :not_found
        end
      end

      private

      def family_tree_params
        params.require(:family_tree).permit(:name, :description, :privacy_setting)
      end
    end
  end
end 