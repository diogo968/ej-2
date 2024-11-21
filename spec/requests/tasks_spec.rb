require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  let!(:tasks) { Task.create([{ title: 'Task 1', completed: false }, { title: 'Task 2', completed: true }]) }
  let(:task_id) { tasks.first.id }

  describe 'GET /tasks' do
    it 'returns all tasks' do
      get '/tasks'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'GET /tasks/:id' do
    it 'returns the task' do
      get "/tasks/#{task_id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(task_id)
    end

    it 'returns 404 for non-existent task' do
      get '/tasks/999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /tasks' do
    let(:valid_params) { { task: { title: 'New Task', completed: false } } }

    it 'creates a new task' do
      expect {
        post '/tasks', params: valid_params
      }.to change(Task, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns errors for invalid input' do
      post '/tasks', params: { task: { completed: false } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /tasks/:id' do
    let(:valid_params) { { task: { title: 'Updated Task' } } }

    it 'updates the task' do
      put "/tasks/#{task_id}", params: valid_params
      expect(response).to have_http_status(:ok)
      expect(Task.find(task_id).title).to eq('Updated Task')
    end

    it 'returns errors for invalid input' do
      put "/tasks/#{task_id}", params: { task: { title: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 for non-existent task' do
      get '/tasks/999'
      expect(response).to have_http_status(:not_found)
    end    
  end

  describe 'DELETE /tasks/:id' do
    it 'deletes the task' do
      expect {
        delete "/tasks/#{task_id}"
      }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
