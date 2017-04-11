require 'spec_helper'

describe RelationshipsController do
  describe 'GET index' do
    it 'sets @relationships to the current user\'s relationships' do
      jacky = Fabricate(:user)
      set_current_user(jacky)
      richard = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: jacky, leader: richard)
      get :index
      expect(assigns(:relationships)).to eq([relationship])
    end

    it_behaves_like 'requires sign in' do
      let(:action) { get :index }
    end
  end

  describe 'DELETE destroy' do
    it_behaves_like 'requires sign in' do
      let(:action) { delete :destroy, id: 4}
    end

    it 'deletes the relationship if the current user is the follower' do
      jacky = Fabricate(:user)
      set_current_user(jacky)
      richard = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: jacky, leader: richard)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(0)
    end

    it 'redirects to the people page' do
      jacky = Fabricate(:user)
      set_current_user(jacky)
      richard = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: jacky, leader: richard)
      delete :destroy, id: relationship.id
      expect(response).to redirect_to(people_path)
    end

    it 'does not delete the relationship if the current user is not the follower' do
      jacky = Fabricate(:user)
      set_current_user(jacky)
      richard = Fabricate(:user)
      kevin = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: kevin, leader: richard)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(1)
    end
  end

  describe 'POST create' do
    it_behaves_like 'requires sign in' do
      let(:action) { post :create, leader_id: 3}
    end

    it 'creates a relationship that the current user follows the leader' do
      richard = Fabricate(:user)
      jacky = Fabricate(:user)
      set_current_user(jacky)
      post :create, leader_id: richard.id
      expect(jacky.following_relationships.first.leader).to eq(richard)
    end

    it 'redirects to the people page' do
      richard = Fabricate(:user)
      jacky = Fabricate(:user)
      set_current_user(jacky)
      post :create, leader_id: richard.id
      expect(response).to redirect_to(people_path)
    end

    it 'does not create a relationship if the current user already follows the leader' do
      richard = Fabricate(:user)
      jacky = Fabricate(:user)
      set_current_user(jacky)
      Fabricate(:relationship, leader: richard, follower: jacky)
      post :create, leader_id: richard.id
      expect(Relationship.count).to eq(1)
    end

    it 'does not allow one to follow themselves' do
      richard = Fabricate(:user)
      set_current_user(richard)
      post :create, leader_id: richard.id
      expect(Relationship.count).to be(0)
    end
  end
end
