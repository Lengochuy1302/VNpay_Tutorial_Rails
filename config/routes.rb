Rails.application.routes.draw do
	root'bod#new'
	# bod
	get 'new' => 'bod#new'
	get 'details' => 'bod#details'
	get 'payment' => 'bod#payment'
    get 'checkouts' => 'bod#checkouts'
	get 'fallback' => 'bod#fallback'

	# admin
	get 'admin' => 'admin#admin'
	get 'create' => 'admin#create'
	post 'insert' => 'admin#insert'
	post 'getImage' => 'admin#getImage'

  end
  