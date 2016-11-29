Rails.application.routes.draw do
  get 'welcome/index'
  post 'welcome/index'
  post 'welcome/getUserDateAndRoute'
  post 'welcome/getRouteVariant'
  post 'welcome/getFromToStops'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
