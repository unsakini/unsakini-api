
App.config [
  '$stateProvider'
  '$urlRouterProvider'
  ($stateProvider, $urlRouterProvider) ->

    $urlRouterProvider.otherwise '/dashboard'

    $stateProvider
    .state 'list',
      url: '/dashboard'
      templateUrl: 'home.html'
      # controller: 'ListCtrl as ListCtrl'

    .state 'list.new',
      url: '/new'
      templateUrl: 'list/new.html'
      controller: 'NewListCtrl as NewListCtrl'

    .state 'list.items',
      url: '/:id'
      templateUrl: 'item/index.html'
      controller: 'ShowListCtrl as ShowListCtrl'

    .state 'list.new_item',
      url: '/:id/new'
      templateUrl: 'item/new.html'
      controller: 'NewItemCtrl as NewItemCtrl'

    .state 'list.edit_item',
      url: '/:list_id/item/:item_id/edit'
      templateUrl: 'item/edit.html'
      controller: 'EditItemCtrl as EditItemCtrl'

]