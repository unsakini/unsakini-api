import { Injectable }     from '@angular/core';
import { Http } from '@angular/http';

// import {Observable} from 'rxjs/Rx';
import {BehaviorSubject} from 'rxjs/BehaviorSubject';
import {Observable} from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';

import {UserModel} from '../models/user.model';
import {CryptoService} from './crypto.service';

@Injectable()

export class UserService {

  static currentUser: UserModel;
  public currentUser$: BehaviorSubject<UserModel> = new BehaviorSubject<UserModel>(new UserModel());
  private fetchingCurrentUserObservable: any;

  constructor (private http: Http) { }

  getCurrentUser (cached?: boolean): Observable<UserModel> {
    if (cached && UserService.currentUser) {
      return Observable.of(UserService.currentUser);
    } else {
      if (this.fetchingCurrentUserObservable) {
        return this.fetchingCurrentUserObservable;
      }
      this.fetchingCurrentUserObservable = new Observable<UserModel>((observable) => {
        this.http.get('/user').map(
          (res) => {
            return res.json();
          }
        ).subscribe((json) => {
          CryptoService.setKeyName(json);
          UserService.currentUser = new UserModel(json);
          this.currentUser$.next(UserService.currentUser);
          observable.next(UserService.currentUser);
          observable.complete();
          this.fetchingCurrentUserObservable = null;
          return UserService.currentUser;
        });
      });
      return this.fetchingCurrentUserObservable;
    }
  }

}
