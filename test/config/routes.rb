# frozen_string_literal: true

Dummy::Application.routes.draw do
  get "*path", to: "application#show"
  resources :application, param: :page, path: ""
end
