# -*- encoding : utf-8 -*-
require 'test_helper'

class CodeGensControllerTest < ActionController::TestCase
  setup do
    @code_gen = code_gens(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:code_gens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create code_gen" do
    assert_difference('CodeGen.count') do
      post :create, code_gen: { package_name: @code_gen.package_name, project_name: @code_gen.project_name, table_name: @code_gen.table_name }
    end

    assert_redirected_to code_gen_path(assigns(:code_gen))
  end

  test "should show code_gen" do
    get :show, id: @code_gen
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @code_gen
    assert_response :success
  end

  test "should update code_gen" do
    patch :update, id: @code_gen, code_gen: { package_name: @code_gen.package_name, project_name: @code_gen.project_name, table_name: @code_gen.table_name }
    assert_redirected_to code_gen_path(assigns(:code_gen))
  end

  test "should destroy code_gen" do
    assert_difference('CodeGen.count', -1) do
      delete :destroy, id: @code_gen
    end

    assert_redirected_to code_gens_path
  end
end
