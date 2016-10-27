import {NgModule} from '@angular/core';
import {RouterModule} from '@angular/router';

import {SettingsComponent} from './settings.component';
import {SettingsMainComponent} from './main/settings.main.component';
import {CanActivateSettings} from '../services/can-activate-settings.route.guard';

@NgModule({
  imports: [
    RouterModule.forChild([
      {
        path: 'settings',
        component: SettingsComponent,
        canActivate: ['canActivateSettings'],
        children: [
          {
            path: '',
            component: SettingsMainComponent
          }
        ]
      }
    ])
  ],
  providers: [
    {
      provide: 'canActivateSettings',
      useClass: CanActivateSettings
    }
  ],
  exports: [
    RouterModule
  ]
})

export class SettingsRoutingModule {

}
