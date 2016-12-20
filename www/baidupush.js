
var exec = require('cordova/exec');

var BaiduPush = {
  registered: false,
  
  init: function() {
        return new BaiduPush();
  },
  
  registerChannel: function(api_key,  successCallback ) {
    exec( successCallback, BaiduPush.failureFn, 'BaiduPush', 'registerChannel', [api_key]);
  },
  
  startWork: function(api_key, successCallback) {
    exec(successCallback, BaiduPush.failureFn, 'BaiduPush', 'startWork', [api_key]);
  },
  
  stopWork: function(successCallback) {
    exec(successCallback, BaiduPush.failureFn, 'BaiduPush', 'stopWork', []);
  },
  
  resumeWork: function(successCallback) {
    exec(successCallback, BaiduPush.failureFn, 'BaiduPush', 'resumeWork', []);
  },
  
  setTags: function(tags, successCallback) {
    exec(successCallback, BaiduPush.failureFn, 'BaiduPush', 'setTags', tags);
  },
  
  delTags: function(tags, successCallback) {
    exec(successCallback, BaiduPush.failureFn, 'BaiduPush', 'delTags', tags);
  },
  
  setApplicationIconBadgeNumber: function( badge,  successCallback ) {
    exec( successCallback, BaiduPush.failureFn, 'BaiduPush', 'setApplicationIconBadgeNumber', [badge]);
  },
  
  getApplicationIconBadgeNumber: function( successCallback ) {
    exec( successCallback, BaiduPush.failureFn, 'BaiduPush', 'getApplicationIconBadgeNumber', [] );
  },
  
  clearAllNotifications: function( successCallback ) {
    exec( successCallback, BaiduPush.failureFn, 'BaiduPush', 'clearAllNotifications', [] );
  },
  
  hasPermission: function( successCallback ) {
    exec( successCallback, BaiduPush.failureFn, 'BaiduPush', 'hasPermission', [] );
  },
  
  failureFn: function() {
    console.log('fail to register push');
  },
  BaiduPush: BaiduPush
}

module.exports = BaiduPush;