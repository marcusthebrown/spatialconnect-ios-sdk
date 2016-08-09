'use strict';

var actions = require('./actions.json');
var fs = require('fs');
var _ = require('lodash');
var Rx = require('rx');

var objchead = '/*This file is autogenerated. Do not edit.*/\n#ifndef SpatialConnect_SCJavascriptCommands_h\n' +
'#define SpatialConnect_SCJavascriptCommands_h\n\n';

//Objective-C Output
var first = true;
Rx.Observable.create((sub) => {
  _.mapKeys(actions,(v,k) => {
    var val = '';
    if (!first) {
      val += ',\n';
    }
    val += '\t' + k + ' = ' + v;
    sub.onNext(val);
    first = false;
  });
  sub.onCompleted();
}).reduce((acc,v) => {
  return acc + v;
},objchead+'typedef NS_ENUM(NSInteger, SCCommand) {\n')
  .subscribe(
    (d) => {
      fs.writeFileSync('Commands.h',d+'\n};\n#endif');
    }
  );

var javahead = 'package com.boundlessgeo.spatialconnect.bridge;\n\n';
first = true;
Rx.Observable.create((sub) => {
  _.mapKeys(actions,(v,k) => {
    var val = '';
    if (!first) {
      val += ',\n';
    }
    val += '\t' + k + '(' + v + ')';
    sub.onNext(val);
    first = false;
  });
  sub.onCompleted();
}).reduce((acc,v) => {
  return acc + v;
},javahead+'public enum SCCommand {\n')
  .subscribe(
    (d) => {
      fs.writeFileSync('Commands.java',d+';\n};\n');
    }
  );
