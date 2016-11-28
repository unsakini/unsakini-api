import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

import { DashboardRoutesModule } from './dashboard.routes.module';
import { DashboardComponent } from './dashboard.component';
import { HomeComponent } from './home/home.component';

@NgModule({
  imports: [
    CommonModule,
    RouterModule,
    DashboardRoutesModule,
  ],
  declarations: [
    DashboardComponent,
    HomeComponent
  ]
})
export class DashboardModule { }
