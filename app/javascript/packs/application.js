// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from '@rails/activestorage';
import 'channels';
import 'bootstrap/dist/js/bootstrap';
import 'jquery';
import './daily_goal.js'; // 1日あたりのページ数計算
import './search_form.js'; //書籍検索を空白時に無効化
import './toggle_menu.js'; //ヘッダーのトグルメニュー

Rails.start();
Turbolinks.start();
ActiveStorage.start();
