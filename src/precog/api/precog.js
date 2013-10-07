/*
 *  _       _                     _   
 * | |     | |                   | |  
 * | | __ _| |__   ___ ___   __ _| |_               Labcoat (R)
 * | |/ _` | '_ \ / __/ _ \ / _` | __|              Powerful development environment for Quirrel.
 * | | (_| | |_) | (_| (_) | (_| | |_               Copyright (C) 2010 - 2013 SlamData, Inc.
 * |_|\__,_|_.__/ \___\___/ \__,_|\__|              All Rights Reserved.
 *
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 
 * 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See 
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this 
 * program. If not, see <http://www.gnu.org/licenses/>.
 *
 */
/**
 * The API exported by the Precog JS Client.
 * @namespace precog
 */
(function(definition) {
  if (typeof bootstrap === "function") {
    // Montage Require
    bootstrap("precog", definition);
  } else if (typeof exports === "object") {
    // CommonJS
    module.exports = definition();
  } else if (typeof define === "function") {
    // RequireJS
    define(definition);
  } else if (typeof ses !== "undefined") {
    // SES (Secure EcmaScript)
    if (!ses.ok()) return;
    ses.makePrecog = definition;
  } else {
    // <script>
    window.Precog = definition();
  }
})(function() {
  /*
              DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                      Version 2, December 2004
  
   Copyright (c) 2011..2012 David Chambers <dc@hashify.me>
  
   Everyone is permitted to copy and distribute verbatim or modified
   copies of this license document, and changing it is allowed as long
   as the name is changed.
  
              DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
     TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
  
    0. You just DO WHAT THE FUCK YOU WANT TO.
  */
  ;(function () {
  
    var
      object = typeof window != 'undefined' ? window : exports,
      chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=',
      INVALID_CHARACTER_ERR = (function () {
        // fabricate a suitable error object
        try { document.createElement('$'); }
        catch (error) { return error; }}());
  
    // encoder
    // [https://gist.github.com/999166] by [https://github.com/nignag]
    object.btoa || (
    object.btoa = function (input) {
      for (
        // initialize result and counter
        var block, charCode, idx = 0, map = chars, output = '';
        // if the next input index does not exist:
        //   change the mapping table to "="
        //   check if d has no fractional digits
        input.charAt(idx | 0) || (map = '=', idx % 1);
        // "8 - idx % 1 * 8" generates the sequence 2, 4, 6, 8
        output += map.charAt(63 & block >> 8 - idx % 1 * 8)
      ) {
        charCode = input.charCodeAt(idx += 3/4);
        if (charCode > 0xFF) throw INVALID_CHARACTER_ERR;
        block = block << 8 | charCode;
      }
      return output;
    });
  
    // decoder
    // [https://gist.github.com/1020396] by [https://github.com/atk]
    object.atob || (
    object.atob = function (input) {
      input = input.replace(/=+$/, '')
      if (input.length % 4 == 1) throw INVALID_CHARACTER_ERR;
      for (
        // initialize result and counters
        var bc = 0, bs, buffer, idx = 0, output = '';
        // get next character
        buffer = input.charAt(idx++);
        // character found in table? initialize bit storage and add its ascii value;
        ~buffer && (bs = bc % 4 ? bs * 64 + buffer : buffer,
          // and if not first of each 4 characters,
          // convert the first 8 bits to one ascii character
          bc++ % 4) ? output += String.fromCharCode(255 & bs >> (-2 * bc & 6)) : 0
      ) {
        // try to find character in table (0-63, not found => -1)
        buffer = chars.indexOf(buffer);
      }
      return output;
    });
  
  }());

  /*
      json2.js
      2012-10-08
  
      Public Domain.
  
      NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
  
      See http://www.JSON.org/js.html
  
  
      This code should be minified before deployment.
      See http://javascript.crockford.com/jsmin.html
  
      USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
      NOT CONTROL.
  
  
      This file creates a global JSON object containing two methods: stringify
      and parse.
  
          JSON.stringify(value, replacer, space)
              value       any JavaScript value, usually an object or array.
  
              replacer    an optional parameter that determines how object
                          values are stringified for objects. It can be a
                          function or an array of strings.
  
              space       an optional parameter that specifies the indentation
                          of nested structures. If it is omitted, the text will
                          be packed without extra whitespace. If it is a number,
                          it will specify the number of spaces to indent at each
                          level. If it is a string (such as '\t' or '&nbsp;'),
                          it contains the characters used to indent at each level.
  
              This method produces a JSON text from a JavaScript value.
  
              When an object value is found, if the object contains a toJSON
              method, its toJSON method will be called and the result will be
              stringified. A toJSON method does not serialize: it returns the
              value represented by the name/value pair that should be serialized,
              or undefined if nothing should be serialized. The toJSON method
              will be passed the key associated with the value, and this will be
              bound to the value
  
              For example, this would serialize Dates as ISO strings.
  
                  Date.prototype.toJSON = function (key) {
                      function f(n) {
                          // Format integers to have at least two digits.
                          return n < 10 ? '0' + n : n;
                      }
  
                      return this.getUTCFullYear()   + '-' +
                           f(this.getUTCMonth() + 1) + '-' +
                           f(this.getUTCDate())      + 'T' +
                           f(this.getUTCHours())     + ':' +
                           f(this.getUTCMinutes())   + ':' +
                           f(this.getUTCSeconds())   + 'Z';
                  };
  
              You can provide an optional replacer method. It will be passed the
              key and value of each member, with this bound to the containing
              object. The value that is returned from your method will be
              serialized. If your method returns undefined, then the member will
              be excluded from the serialization.
  
              If the replacer parameter is an array of strings, then it will be
              used to select the members to be serialized. It filters the results
              such that only members with keys listed in the replacer array are
              stringified.
  
              Values that do not have JSON representations, such as undefined or
              functions, will not be serialized. Such values in objects will be
              dropped; in arrays they will be replaced with null. You can use
              a replacer function to replace those with JSON values.
              JSON.stringify(undefined) returns undefined.
  
              The optional space parameter produces a stringification of the
              value that is filled with line breaks and indentation to make it
              easier to read.
  
              If the space parameter is a non-empty string, then that string will
              be used for indentation. If the space parameter is a number, then
              the indentation will be that many spaces.
  
              Example:
  
              text = JSON.stringify(['e', {pluribus: 'unum'}]);
              // text is '["e",{"pluribus":"unum"}]'
  
  
              text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
              // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'
  
              text = JSON.stringify([new Date()], function (key, value) {
                  return this[key] instanceof Date ?
                      'Date(' + this[key] + ')' : value;
              });
              // text is '["Date(---current time---)"]'
  
  
          JSON.parse(text, reviver)
              This method parses a JSON text to produce an object or array.
              It can throw a SyntaxError exception.
  
              The optional reviver parameter is a function that can filter and
              transform the results. It receives each of the keys and values,
              and its return value is used instead of the original value.
              If it returns what it received, then the structure is not modified.
              If it returns undefined then the member is deleted.
  
              Example:
  
              // Parse the text. Values that look like ISO date strings will
              // be converted to Date objects.
  
              myData = JSON.parse(text, function (key, value) {
                  var a;
                  if (typeof value === 'string') {
                      a =
  /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                      if (a) {
                          return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                              +a[5], +a[6]));
                      }
                  }
                  return value;
              });
  
              myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                  var d;
                  if (typeof value === 'string' &&
                          value.slice(0, 5) === 'Date(' &&
                          value.slice(-1) === ')') {
                      d = new Date(value.slice(5, -1));
                      if (d) {
                          return d;
                      }
                  }
                  return value;
              });
  
  
      This is a reference implementation. You are free to copy, modify, or
      redistribute.
  */
  
  /*jslint evil: true, regexp: true */
  
  /*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
      call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
      getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
      lastIndex, length, parse, prototype, push, replace, slice, stringify,
      test, toJSON, toString, valueOf
  */
  
  
  // Create a JSON object only if one does not already exist. We create the
  // methods in a closure to avoid creating global variables.
  
  if (typeof JSON !== 'object') {
      JSON = {};
  }
  
  (function () {
      'use strict';
  
      function f(n) {
          // Format integers to have at least two digits.
          return n < 10 ? '0' + n : n;
      }
  
      if (typeof Date.prototype.toJSON !== 'function') {
  
          Date.prototype.toJSON = function (key) {
  
              return isFinite(this.valueOf())
                  ? this.getUTCFullYear()     + '-' +
                      f(this.getUTCMonth() + 1) + '-' +
                      f(this.getUTCDate())      + 'T' +
                      f(this.getUTCHours())     + ':' +
                      f(this.getUTCMinutes())   + ':' +
                      f(this.getUTCSeconds())   + 'Z'
                  : null;
          };
  
          String.prototype.toJSON      =
              Number.prototype.toJSON  =
              Boolean.prototype.toJSON = function (key) {
                  return this.valueOf();
              };
      }
  
      var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
          escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
          gap,
          indent,
          meta = {    // table of character substitutions
              '\b': '\\b',
              '\t': '\\t',
              '\n': '\\n',
              '\f': '\\f',
              '\r': '\\r',
              '"' : '\\"',
              '\\': '\\\\'
          },
          rep;
  
  
      function quote(string) {
  
  // If the string contains no control characters, no quote characters, and no
  // backslash characters, then we can safely slap some quotes around it.
  // Otherwise we must also replace the offending characters with safe escape
  // sequences.
  
          escapable.lastIndex = 0;
          return escapable.test(string) ? '"' + string.replace(escapable, function (a) {
              var c = meta[a];
              return typeof c === 'string'
                  ? c
                  : '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
          }) + '"' : '"' + string + '"';
      }
  
  
      function str(key, holder) {
  
  // Produce a string from holder[key].
  
          var i,          // The loop counter.
              k,          // The member key.
              v,          // The member value.
              length,
              mind = gap,
              partial,
              value = holder[key];
  
  // If the value has a toJSON method, call it to obtain a replacement value.
  
          if (value && typeof value === 'object' &&
                  typeof value.toJSON === 'function') {
              value = value.toJSON(key);
          }
  
  // If we were called with a replacer function, then call the replacer to
  // obtain a replacement value.
  
          if (typeof rep === 'function') {
              value = rep.call(holder, key, value);
          }
  
  // What happens next depends on the value's type.
  
          switch (typeof value) {
          case 'string':
              return quote(value);
  
          case 'number':
  
  // JSON numbers must be finite. Encode non-finite numbers as null.
  
              return isFinite(value) ? String(value) : 'null';
  
          case 'boolean':
          case 'null':
  
  // If the value is a boolean or null, convert it to a string. Note:
  // typeof null does not produce 'null'. The case is included here in
  // the remote chance that this gets fixed someday.
  
              return String(value);
  
  // If the type is 'object', we might be dealing with an object or an array or
  // null.
  
          case 'object':
  
  // Due to a specification blunder in ECMAScript, typeof null is 'object',
  // so watch out for that case.
  
              if (!value) {
                  return 'null';
              }
  
  // Make an array to hold the partial results of stringifying this object value.
  
              gap += indent;
              partial = [];
  
  // Is the value an array?
  
              if (Object.prototype.toString.apply(value) === '[object Array]') {
  
  // The value is an array. Stringify every element. Use null as a placeholder
  // for non-JSON values.
  
                  length = value.length;
                  for (i = 0; i < length; i += 1) {
                      partial[i] = str(i, value) || 'null';
                  }
  
  // Join all of the elements together, separated with commas, and wrap them in
  // brackets.
  
                  v = partial.length === 0
                      ? '[]'
                      : gap
                      ? '[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']'
                      : '[' + partial.join(',') + ']';
                  gap = mind;
                  return v;
              }
  
  // If the replacer is an array, use it to select the members to be stringified.
  
              if (rep && typeof rep === 'object') {
                  length = rep.length;
                  for (i = 0; i < length; i += 1) {
                      if (typeof rep[i] === 'string') {
                          k = rep[i];
                          v = str(k, value);
                          if (v) {
                              partial.push(quote(k) + (gap ? ': ' : ':') + v);
                          }
                      }
                  }
              } else {
  
  // Otherwise, iterate through all of the keys in the object.
  
                  for (k in value) {
                      if (Object.prototype.hasOwnProperty.call(value, k)) {
                          v = str(k, value);
                          if (v) {
                              partial.push(quote(k) + (gap ? ': ' : ':') + v);
                          }
                      }
                  }
              }
  
  // Join all of the member texts together, separated with commas,
  // and wrap them in braces.
  
              v = partial.length === 0
                  ? '{}'
                  : gap
                  ? '{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}'
                  : '{' + partial.join(',') + '}';
              gap = mind;
              return v;
          }
      }
  
  // If the JSON object does not yet have a stringify method, give it one.
  
      if (typeof JSON.stringify !== 'function') {
          JSON.stringify = function (value, replacer, space) {
  
  // The stringify method takes a value and an optional replacer, and an optional
  // space parameter, and returns a JSON text. The replacer can be a function
  // that can replace values, or an array of strings that will select the keys.
  // A default replacer method can be provided. Use of the space parameter can
  // produce text that is more easily readable.
  
              var i;
              gap = '';
              indent = '';
  
  // If the space parameter is a number, make an indent string containing that
  // many spaces.
  
              if (typeof space === 'number') {
                  for (i = 0; i < space; i += 1) {
                      indent += ' ';
                  }
  
  // If the space parameter is a string, it will be used as the indent string.
  
              } else if (typeof space === 'string') {
                  indent = space;
              }
  
  // If there is a replacer, it must be a function or an array.
  // Otherwise, throw an error.
  
              rep = replacer;
              if (replacer && typeof replacer !== 'function' &&
                      (typeof replacer !== 'object' ||
                      typeof replacer.length !== 'number')) {
                  throw new Error('JSON.stringify');
              }
  
  // Make a fake root object containing our value under the key of ''.
  // Return the result of stringifying the value.
  
              return str('', {'': value});
          };
      }
  
  
  // If the JSON object does not yet have a parse method, give it one.
  
      if (typeof JSON.parse !== 'function') {
          JSON.parse = function (text, reviver) {
  
  // The parse method takes a text and an optional reviver function, and returns
  // a JavaScript value if the text is a valid JSON text.
  
              var j;
  
              function walk(holder, key) {
  
  // The walk method is used to recursively walk the resulting structure so
  // that modifications can be made.
  
                  var k, v, value = holder[key];
                  if (value && typeof value === 'object') {
                      for (k in value) {
                          if (Object.prototype.hasOwnProperty.call(value, k)) {
                              v = walk(value, k);
                              if (v !== undefined) {
                                  value[k] = v;
                              } else {
                                  delete value[k];
                              }
                          }
                      }
                  }
                  return reviver.call(holder, key, value);
              }
  
  
  // Parsing happens in four stages. In the first stage, we replace certain
  // Unicode characters with escape sequences. JavaScript handles many characters
  // incorrectly, either silently deleting them, or treating them as line endings.
  
              text = String(text);
              cx.lastIndex = 0;
              if (cx.test(text)) {
                  text = text.replace(cx, function (a) {
                      return '\\u' +
                          ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                  });
              }
  
  // In the second stage, we run the text against regular expressions that look
  // for non-JSON patterns. We are especially concerned with '()' and 'new'
  // because they can cause invocation, and '=' because it can cause mutation.
  // But just to be safe, we want to reject all unexpected forms.
  
  // We split the second stage into 4 regexp operations in order to work around
  // crippling inefficiencies in IE's and Safari's regexp engines. First we
  // replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
  // replace all simple value tokens with ']' characters. Third, we delete all
  // open brackets that follow a colon or comma or that begin the text. Finally,
  // we look to see that the remaining characters are only whitespace or ']' or
  // ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.
  
              if (/^[\],:{}\s]*$/
                      .test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                          .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
                          .replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {
  
  // In the third stage we use the eval function to compile the text into a
  // JavaScript structure. The '{' operator is subject to a syntactic ambiguity
  // in JavaScript: it can begin a block or an object literal. We wrap the text
  // in parens to eliminate the ambiguity.
  
                  j = eval('(' + text + ')');
  
  // In the optional fourth stage, we recursively walk the new structure, passing
  // each name/value pair to a reviver function for possible transformation.
  
                  return typeof reviver === 'function'
                      ? walk({'': j}, '')
                      : j;
              }
  
  // If the text is not JSON parseable, then a SyntaxError is thrown.
  
              throw new SyntaxError('JSON.parse');
          };
      }
  }());

  if (typeof window !== 'undefined') {
    /** HTML5 sessionStorage
     * @build       2009-08-20 23:35:12
     * @author      Andrea Giammarchi
     * @license     Mit Style License
     * @project     http://code.google.com/p/sessionstorage/
     */if(typeof sessionStorage==="undefined"){(function(j){var k=j;try{while(k!==k.top){k=k.top}}catch(i){}var f=(function(e,n){return{decode:function(o,p){return this.encode(o,p)},encode:function(y,u){for(var p=y.length,w=u.length,o=[],x=[],v=0,s=0,r=0,q=0,t;v<256;++v){x[v]=v}for(v=0;v<256;++v){s=(s+(t=x[v])+y.charCodeAt(v%p))%256;x[v]=x[s];x[s]=t}for(s=0;r<w;++r){v=r%256;s=(s+(t=x[v]))%256;p=x[v]=x[s];x[s]=t;o[q++]=e(u.charCodeAt(r)^x[(p+t)%256])}return o.join("")},key:function(q){for(var p=0,o=[];p<q;++p){o[p]=e(1+((n()*255)<<0))}return o.join("")}}})(j.String.fromCharCode,j.Math.random);var a=(function(n){function o(r,q,p){this._i=(this._data=p||"").length;if(this._key=q){this._storage=r}else{this._storage={_key:r||""};this._key="_key"}}o.prototype.c=String.fromCharCode(1);o.prototype._c=".";o.prototype.clear=function(){this._storage[this._key]=this._data};o.prototype.del=function(p){var q=this.get(p);if(q!==null){this._storage[this._key]=this._storage[this._key].replace(e.call(this,p,q),"")}};o.prototype.escape=n.escape;o.prototype.get=function(q){var s=this._storage[this._key],t=this.c,p=s.indexOf(q=t.concat(this._c,this.escape(q),t,t),this._i),r=null;if(-1<p){p=s.indexOf(t,p+q.length-1)+1;r=s.substring(p,p=s.indexOf(t,p));r=this.unescape(s.substr(++p,r))}return r};o.prototype.key=function(){var u=this._storage[this._key],v=this.c,q=v+this._c,r=this._i,t=[],s=0,p=0;while(-1<(r=u.indexOf(q,r))){t[p++]=this.unescape(u.substring(r+=2,s=u.indexOf(v,r)));r=u.indexOf(v,s)+2;s=u.indexOf(v,r);r=1+s+1*u.substring(r,s)}return t};o.prototype.set=function(p,q){this.del(p);this._storage[this._key]+=e.call(this,p,q)};o.prototype.unescape=n.unescape;function e(p,q){var r=this.c;return r.concat(this._c,this.escape(p),r,r,(q=this.escape(q)).length,r,q)}return o})(j);if(Object.prototype.toString.call(j.opera)==="[object Opera]"){history.navigationMode="compatible";a.prototype.escape=j.encodeURIComponent;a.prototype.unescape=j.decodeURIComponent}function l(){function r(){s.cookie=["sessionStorage="+j.encodeURIComponent(h=f.key(128))].join(";");g=f.encode(h,g);a=new a(k,"name",k.name)}var e=k.name,s=k.document,n=/\bsessionStorage\b=([^;]+)(;|$)/,p=n.exec(s.cookie),q;if(p){h=j.decodeURIComponent(p[1]);g=f.encode(h,g);a=new a(k,"name");for(var t=a.key(),q=0,o=t.length,u={};q<o;++q){if((p=t[q]).indexOf(g)===0){b.push(p);u[p]=a.get(p);a.del(p)}}a=new a.constructor(k,"name",k.name);if(0<(this.length=b.length)){for(q=0,o=b.length,c=a.c,p=[];q<o;++q){p[q]=c.concat(a._c,a.escape(t=b[q]),c,c,(t=a.escape(u[t])).length,c,t)}k.name+=p.join("")}}else{r();if(!n.exec(s.cookie)){b=null}}}l.prototype={length:0,key:function(e){if(typeof e!=="number"||e<0||b.length<=e){throw"Invalid argument"}return b[e]},getItem:function(e){e=g+e;if(d.call(m,e)){return m[e]}var n=a.get(e);if(n!==null){n=m[e]=f.decode(h,n)}return n},setItem:function(e,n){this.removeItem(e);e=g+e;a.set(e,f.encode(h,m[e]=""+n));this.length=b.push(e)},removeItem:function(e){var n=a.get(e=g+e);if(n!==null){delete m[e];a.del(e);this.length=b.remove(e)}},clear:function(){a.clear();m={};b.length=0}};var g=k.document.domain,b=[],m={},d=m.hasOwnProperty,h;b.remove=function(n){var e=this.indexOf(n);if(-1<e){this.splice(e,1)}return this.length};if(!b.indexOf){b.indexOf=function(o){for(var e=0,n=this.length;e<n;++e){if(this[e]===o){return e}}return -1}}if(k.sessionStorage){l=function(){};l.prototype=k.sessionStorage}l=new l;if(b!==null){j.sessionStorage=l}})(window)};
  } else {
    var storage = {};

    localStorage = {
      setItem: function(key, value) {
        storage[key] = value;
      },

      getItem: function(key) {
        return storage[key];
      },

      removeItem: function(key) {
        delete storage[key];
      }
    };
  }

  /**
   * Vow
   *
   * Copyright (c) 2012-2013 Filatov Dmitry (dfilatov@yandex-team.ru)
   * Dual licensed under the MIT and GPL licenses:
   * http://www.opensource.org/licenses/mit-license.php
   * http://www.gnu.org/licenses/gpl.html
   *
   * @version 0.3.1
   */
  
  (function(global) {
  
  var Promise = function(val) {
      this._res = val;
  
      this._isFulfilled = !!arguments.length;
      this._isRejected = false;
  
      this._fulfilledCallbacks = [];
      this._rejectedCallbacks = [];
      this._progressCallbacks = [];
  };
  
  Promise.prototype = {
      valueOf : function() {
          return this._res;
      },
  
      isFulfilled : function() {
          return this._isFulfilled;
      },
  
      isRejected : function() {
          return this._isRejected;
      },
  
      isResolved : function() {
          return this._isFulfilled || this._isRejected;
      },
  
      fulfill : function(val) {
          if(this.isResolved()) {
              return;
          }
  
          this._isFulfilled = true;
          this._res = val;
  
          this._callCallbacks(this._fulfilledCallbacks, val);
          this._fulfilledCallbacks = this._rejectedCallbacks = this._progressCallbacks = undef;
      },
  
      reject : function(err) {
          if(this.isResolved()) {
              return;
          }
  
          this._isRejected = true;
          this._res = err;
  
          this._callCallbacks(this._rejectedCallbacks, err);
          this._fulfilledCallbacks = this._rejectedCallbacks = this._progressCallbacks = undef;
      },
  
      notify : function(val) {
          if(this.isResolved()) {
              return;
          }
  
          this._callCallbacks(this._progressCallbacks, val);
      },
  
      then : function(onFulfilled, onRejected, onProgress) {
          var promise = new Promise(),
              cb;
  
          if(!this._isRejected) {
              cb = { promise : promise, fn : onFulfilled };
              this._isFulfilled?
                  this._callCallbacks([cb], this._res) :
                  this._fulfilledCallbacks.push(cb);
          }
  
          if(!this._isFulfilled) {
              cb = { promise : promise, fn : onRejected };
              this._isRejected?
                  this._callCallbacks([cb], this._res) :
                  this._rejectedCallbacks.push(cb);
          }
  
          this.isResolved() || this._progressCallbacks.push({ promise : promise, fn : onProgress });
  
          return promise;
      },
  
      fail : function(onRejected) {
          return this.then(undef, onRejected);
      },
  
      always : function(onResolved) {
          var _this = this,
              cb = function() {
                  return onResolved(_this);
              };
  
          return this.then(cb, cb);
      },
  
      progress : function(onProgress) {
          return this.then(undef, undef, onProgress);
      },
  
      spread : function(onFulfilled, onRejected) {
          return this.then(
              function(val) {
                  return onFulfilled.apply(this, val);
              },
              onRejected);
      },
  
      done : function() {
          this.fail(throwException);
      },
  
      delay : function(delay) {
          return this.then(function(val) {
              var promise = new Promise();
              setTimeout(
                  function() {
                      promise.fulfill(val);
                  },
                  delay);
              return promise;
          });
      },
  
      timeout : function(timeout) {
          var promise = new Promise(),
              timer = setTimeout(
                  function() {
                      promise.reject(Error('timed out'));
                  },
                  timeout);
  
          promise.sync(this);
          promise.always(function() {
              clearTimeout(timer);
          });
  
          return promise;
      },
  
      sync : function(promise) {
          var _this = this;
          promise.then(
              function(val) {
                  _this.fulfill(val);
              },
              function(err) {
                  _this.reject(err);
              });
      },
  
      _callCallbacks : function(callbacks, arg) {
          var len = callbacks.length;
          if(!len) {
              return;
          }
  
          var isResolved = this.isResolved(),
              isFulfilled = this.isFulfilled();
  
          nextTick(function() {
              var i = 0, cb, promise, fn;
              while(i < len) {
                  cb = callbacks[i++];
                  promise = cb.promise;
                  fn = cb.fn;
  
                  if(isFunction(fn)) {
                      var res;
                      //try {
                          res = fn(arg);
                      /*}
                      catch(e) {
                          promise.reject(e);
                          continue;
                      }*/
  
                      if(isResolved) {
                          Vow.isPromise(res)?
                              (function(promise) {
                                  res.then(
                                      function(val) {
                                          promise.fulfill(val);
                                      },
                                      function(err) {
                                          promise.reject(err);
                                      })
                              })(promise) :
                              promise.fulfill(res);
                      }
                      else {
                          promise.notify(res);
                      }
                  }
                  else {
                      isResolved?
                          isFulfilled?
                              promise.fulfill(arg) :
                              promise.reject(arg) :
                          promise.notify(arg);
                  }
              }
          });
      }
  };
  
  var Vow = {
      promise : function(val) {
          return arguments.length?
              this.isPromise(val)?
                  val :
                  new Promise(val) :
              new Promise();
      },
  
      when : function(obj, onFulfilled, onRejected, onProgress) {
          return this.promise(obj).then(onFulfilled, onRejected, onProgress);
      },
  
      fail : function(obj, onRejected) {
          return this.when(obj, undef, onRejected);
      },
  
      always : function(obj, onResolved) {
          return this.promise(obj).always(onResolved);
      },
  
      progress : function(obj, onProgress) {
          return this.promise(obj).progress(onProgress);
      },
  
      spread : function(obj, onFulfilled, onRejected) {
          return this.promise(obj).spread(onFulfilled, onRejected);
      },
  
      done : function(obj) {
          this.isPromise(obj) && obj.done();
      },
  
      isPromise : function(obj) {
          return obj && isFunction(obj.then);
      },
  
      valueOf : function(obj) {
          return this.isPromise(obj)? obj.valueOf() : obj;
      },
  
      isFulfilled : function(obj) {
          return this.isPromise(obj)? obj.isFulfilled() : true;
      },
  
      isRejected : function(obj) {
          return this.isPromise(obj)? obj.isRejected() : false;
      },
  
      isResolved : function(obj) {
          return this.isPromise(obj)? obj.isResolved() : true;
      },
  
      fulfill : function(val) {
          return this.when(val, undef, function(err) {
              return err;
          });
      },
  
      reject : function(err) {
          return this.when(err, function(val) {
              var promise = new Promise();
              promise.reject(val);
              return promise;
          });
      },
  
      resolve : function(val) {
          return this.isPromise(val)? val : this.when(val);
      },
  
      invoke : function(fn) {
          //try {
              return this.promise(fn.apply(null, slice.call(arguments, 1)));
          /*}
          catch(e) {
              return this.reject(e);
          }*/
      },
  
      forEach : function(promises, onFulfilled, onRejected, keys) {
          var len = keys? keys.length : promises.length,
              i = 0;
          while(i < len) {
              this.when(promises[keys? keys[i] : i], onFulfilled, onRejected);
              ++i;
          }
      },
  
      all : function(promises) {
          var resPromise = new Promise(),
              isPromisesArray = isArray(promises),
              keys = isPromisesArray?
                  getArrayKeys(promises) :
                  getObjectKeys(promises),
              len = keys.length,
              res = isPromisesArray? [] : {};
  
          if(!len) {
              resPromise.fulfill(res);
              return resPromise;
          }
  
          var i = len,
              onFulfilled = function() {
                  if(!--i) {
                      var j = 0;
                      while(j < len) {
                          res[keys[j]] = Vow.valueOf(promises[keys[j++]]);
                      }
                      resPromise.fulfill(res);
                  }
              },
              onRejected = function(err) {
                  resPromise.reject(err);
              };
  
          this.forEach(promises, onFulfilled, onRejected, keys);
  
          return resPromise;
      },
  
      allResolved : function(promises) {
          var resPromise = new Promise(),
              isPromisesArray = isArray(promises),
              keys = isPromisesArray?
                  getArrayKeys(promises) :
                  getObjectKeys(promises),
              i = keys.length,
              res = isPromisesArray? [] : {};
  
          if(!i) {
              resPromise.fulfill(res);
              return resPromise;
          }
  
          var onProgress = function() {
                  --i || resPromise.fulfill(promises);
              };
  
          this.forEach(promises, onProgress, onProgress, keys);
  
          return resPromise;
      },
  
      any : function(promises) {
          var resPromise = new Promise(),
              len = promises.length;
  
          if(!len) {
              resPromise.reject(Error());
              return resPromise;
          }
  
          var i = 0, err,
              onFulfilled = function(val) {
                  resPromise.fulfill(val);
              },
              onRejected = function(e) {
                  i || (err = e);
                  ++i === len && resPromise.reject(err);
              };
  
          this.forEach(promises, onFulfilled, onRejected);
  
          return resPromise;
      },
  
      delay : function(val, timeout) {
          return this.promise(val).delay(timeout);
      },
  
      timeout : function(val, timeout) {
          return this.promise(val).timeout(timeout);
      }
  };
  
  var undef,
      nextTick = (function() {
          if(typeof process === 'object') { // nodejs
              return process.nextTick;
          }
  
          if(global.setImmediate) { // ie10
              return global.setImmediate;
          }
  
          var fns = [],
              callFns = function() {
                  var fnsToCall = fns, i = 0, len = fns.length;
                  fns = [];
                  while(i < len) {
                      fnsToCall[i++]();
                  }
              };
  
          if(global.postMessage) { // modern browsers
              var isPostMessageAsync = true;
              if(global.attachEvent) {
                  var checkAsync = function() {
                          isPostMessageAsync = false;
                      };
                  global.attachEvent('onmessage', checkAsync);
                  global.postMessage('__checkAsync', '*');
                  global.detachEvent('onmessage', checkAsync);
              }
  
              if(isPostMessageAsync) {
                  var msg = '__promise' + +new Date,
                      onMessage = function(e) {
                          if(e.data === msg) {
                              e.stopPropagation && e.stopPropagation();
                              callFns();
                          }
                      };
  
                  global.addEventListener?
                      global.addEventListener('message', onMessage, true) :
                      global.attachEvent('onmessage', onMessage);
  
                  return function(fn) {
                      fns.push(fn) === 1 && global.postMessage(msg, '*');
                  };
              }
          }
  
          var doc = global.document;
          if('onreadystatechange' in doc.createElement('script')) { // ie6-ie8
              var createScript = function() {
                      var script = doc.createElement('script');
                      script.onreadystatechange = function() {
                          script.parentNode.removeChild(script);
                          script = script.onreadystatechange = null;
                          callFns();
                  };
                  (doc.documentElement || doc.body).appendChild(script);
              };
  
              return function(fn) {
                  fns.push(fn) === 1 && createScript();
              };
          }
  
          return function(fn) { // old browsers
              setTimeout(fn, 0);
          };
      })(),
      throwException = function(e) {
          nextTick(function() {
              throw e;
          });
      },
      isFunction = function(obj) {
          return typeof obj === 'function';
      },
      slice = Array.prototype.slice,
      toStr = Object.prototype.toString,
      isArray = Array.isArray || function(obj) {
          return toStr.call(obj) === '[object Array]';
      },
      getArrayKeys = function(arr) {
          var res = [],
              i = 0, len = arr.length;
          while(i < len) {
              res.push(i++);
          }
          return res;
      },
      getObjectKeys = Object.keys || function(obj) {
          var res = [];
          for(var i in obj) {
              obj.hasOwnProperty(i) && res.push(i);
          }
          return res;
      };
  
  if(typeof exports === 'object') {
      module.exports = Vow;
  }
  else if(typeof modules === 'object') {
      modules.define('vow', function(provide) {
          provide(Vow);
      });
  }
  else if(typeof define === 'function') {
      define(function(require, exports, module) {
          module.exports = Vow;
      });
  }
  else {
      global.Vow = Vow;
  }
  
  })(this);
  if (typeof window == 'undefined') {
    Vow = module.exports;
  }

  /**
   * An HTTP implementation that detects which implementation to use.
   *
   * @constructor http
   * @memberof precog
   *
   * @example
   * PrecogHttp({
   *   basicAuth: {username: "foo", password: "bar"},
   *   method: "GET",
   *   url: "http://api.precog.com",
   *   query: { apiKey: "12321323" },
   *   content: {"foo": "bar"},
   *   success: function(result) { },
   *   failure: function(result) { },
   *   progress: function(status) { }
   * })
   */
  
  function PrecogHttp(options) {
    return PrecogHttp.http(options);
  }
  
  (function(PrecogHttp) {
    var Util = {};
  
    Util.makeBaseAuth = function(user, password) {
      return "Basic " + (typeof btoa != 'undefined' ? btoa : exports.btoa)(user + ':' + password);
    };
  
    Util.addQuery = function(url, query) {
      var hashtagpos = url.lastIndexOf('#'), hash = '';
      if (hashtagpos >= 0) {
        hash = "#" + url.substr(hashtagpos + 1);
        url  = url.substr(0, hashtagpos);
      }
      var suffix = url.indexOf('?') == -1 ? '?' : '&';
      var queries = [];
      for (var name in query) {
        if (query[name] != null) {
          var value = query[name].toString();
  
          if (value.length > 0) {
            queries.push(encodeURIComponent(name) + '=' + encodeURIComponent(value));
          }
        }
      }
      if (queries.length === 0) return url + hash;
      else return url + suffix + queries.join('&') + hash;
    };
  
    Util.parseResponseHeaders = function(xhr) {
      var headers = {};
  
      if (xhr.getAllResponseHeaders) {
        var responseHeaders = xhr.getAllResponseHeaders().split(/\r?\n/);
  
        for (var i = 0; i < responseHeaders.length; i++) {
          if (responseHeaders[i]) {
            var line = responseHeaders[i];
  
            var colonIdx = line.indexOf(':');
  
            var name  = Util.strtrim(line.substr(0, colonIdx));
            var value = Util.strtrim(line.substr(colonIdx + 1));
  
            headers[name] = value;
          }
        }
      }
  
      if (Util.objsize(headers) === 0 && xhr.getResponseHeader) {
        var contentType = xhr.getResponseHeader('Content-Type');
  
        if (contentType) {
          headers["Content-Type"] = contentType;
        }
      }
  
      return headers;
    };
  
    Util.defopts = function(f) {
      var log = function(type, options) {
        return function(v) {
          if (typeof console !== 'undefined') {
            var logger = console[type] || console.info;
  
            logger.call(console, options.method + ' ' + options.url);
            logger.call(console, v);
          }
          if (type !== 'error') return v;
        };
      };
  
      return function(options) {
        var o = {};
  
        o.method   = options.method || 'GET';
        o.url      = Util.addQuery(options.url, options.query);
        o.content  = options.content;
        o.headers  = options.headers || {};
        o.success  = options.success || log('debug', o);
        o.failure  = options.failure || log('error', o);
        o.progress = options.progress || log('debug', o);
        o.sync     = options.sync || false;
  
        if (options.basicAuth) {
          o.headers.Authorization = 
            Util.makeBaseAuth(options.basicAuth.username, options.basicAuth.password);
        }
  
        return f(o);
      };
    };
  
    Util.responseCallback = function(response, success, failure) {
      if (response.status >= 200 && response.status < 300) {
        success(response);
      } else {
        failure(response);
      }
    };
  
    Util.strtrim = function(string) {
      return string.replace(/^\s+|\s+$/g, '');
    };
  
    Util.objsize = function(obj) {
      var size = 0;
      for (var key in obj) {
        if (obj.hasOwnProperty(key)) size++;
      }
      return size;
    };
  
    Util.merge = function(o1, o2) {
      var r = {}, key;
      // Copy:
      for (key in o1) {
        r[key] = o1[key];
      }
      // Merge:
      for (key in o2) {
        r[key] = o2[key];
      }
      return r;
    };
  
    PrecogHttp.createAjax = function() {
      if (window.XMLHttpRequest) return new XMLHttpRequest();
      else return new ActiveXObject("Microsoft.XMLHTTP");
    };
  
    PrecogHttp.http = function(options) {
      if (typeof window === 'undefined') return PrecogHttp.nodejs(options);
      else if ('withCredentials' in PrecogHttp.createAjax()) return PrecogHttp.ajax(options);
      else return PrecogHttp.jsonp(options);
    };
  
    /**
     * @method ajax
     * @memberof precog.http
     * @example
     * PrecogHttp.ajax({
     *   basicAuth: {username: "foo", password: "bar"},
     *   method: "GET",
     *   url: "http://api.precog.com",
     *   query: { apiKey: "12321323" },
     *   content: {"foo": "bar"},
     *   success: function(result) { },
     *   failure: function(result) { },
     *   progress: function(status) { }
     * })
     */
    PrecogHttp.ajax = Util.defopts(function(options) {
      var resolver = Vow.promise();
  
      var request = PrecogHttp.createAjax();
  
      request.open(options.method, options.url, options.sync);
  
      request.upload && (request.upload.onprogress = function(e) {
        if (e.lengthComputable) {
          options.progress({loaded : e.loaded, total : e.total });
        }
      });
  
      request.onreadystatechange = function() {
        var headers = Util.parseResponseHeaders(request);
  
        if (request.readyState === 4) {
          var content = this.responseText;
  
          if (content != null) {
            try {
              var ctype = headers['Content-Type'];
              if (ctype == 'application/json' || ctype == 'text/json')
                content = JSON.parse(this.responseText);
            } catch (e) {}
          }
  
          Util.responseCallback({
            headers:    headers,
            content:    content,
            status:     request.status,
            statusText: request.statusText
          }, function(x) { resolver.fulfill(x); }, function(x) { resolver.reject(x); });
        }
      };
  
      for (var name in options.headers) {
        var value = options.headers[name];
        request.setRequestHeader(name, value);
      }
  
      if (options.content !== undefined) {
        if (options.headers['Content-Type']) {
          request.send(options.content);
        } else {
          request.setRequestHeader('Content-Type', 'application/json');
          request.send(JSON.stringify(options.content));
        }
      } else {
        request.send(null);
      }
  
      return resolver.then(options.success, options.failure);
    });
  
    /**
     * @method jsonp
     * @memberof precog.http
     * @example
     * PrecogHttp.jsonp({
     *   basicAuth: {username: "foo", password: "bar"},
     *   method: "GET",
     *   url: "http://api.precog.com",
     *   query: { apiKey: "12321323" },
     *   content: {"foo": "bar"},
     *   success: function(result) { },
     *   failure: function(result) { },
     *   progress: function(status) { }
     * })
     */
    PrecogHttp.jsonp = Util.defopts(function(options) {
      var random = Math.floor(Math.random() * 214748363);
      var fname  = 'PrecogJsonpCallback' + random.toString();
  
      var resolver = Vow.promise();
  
      window[fname] = function(content, meta) {
        Util.responseCallback({
          headers:    meta.headers,
          content:    content,
          status:     meta.status.code,
          statusText: meta.status.reason
        }, function(x) { resolver.fulfill(x); }, function(x) { resolver.reject(x); });
  
        document.head.removeChild(document.getElementById(fname));
  
        try{
          delete window[fname];
        } catch(e) {
          window[fname] = undefined;
        }
      };
  
      var query = {
        method:   options.method,
        callback: fname
      };
  
      if (options.headers && Util.objsize(options.headers) > 0) {
        query.headers = JSON.stringify(options.headers);
      }
      if (options.content !== undefined) {
        query.content = JSON.stringify(options.content);
      }
  
      var script = document.createElement('SCRIPT');
  
      if (script.addEventListener) {
        script.addEventListener('error',
                                function(e) {
                                  options.failure({
                                    headers:    {},
                                    content:    undefined,
                                    statusText: e.message || 'Failed to load script from server',
                                    statusCode: 400
                                  });
                                },
                                true
                               );
      }
  
      script.setAttribute('type', 'text/javascript');
      script.setAttribute('src',  Util.addQuery(options.url, query));
      script.setAttribute('id',   fname);
  
      // Workaround for document.head being undefined.
      if (!document.head) document.head = document.getElementsByTagName('head')[0];
  
      document.head.appendChild(script);
  
      return resolver.then(options.success, options.failure);
    });
  
    /**
     * @method nodejs
     * @memberof precog.http
     * @example
     * PrecogHttp.nodejs({
     *   basicAuth: {username: "foo", password: "bar"},
     *   method: "GET",
     *   url: "http://api.precog.com",
     *   query: { apiKey: "12321323" },
     *   content: {"foo": "bar"},
     *   success: function(result) { },
     *   failure: function(result) { },
     *   progress: function(status) { }
     * })
     */
    PrecogHttp.nodejs = Util.defopts(function(options) {
      var reqOptions = require('url').parse(options.url);
      var http = require(reqOptions.protocol == 'https:' ? 'https' : 'http');
  
      var resolver = Vow.promise();
  
      reqOptions.method = options.method;
      reqOptions.headers = options.headers;
  
      if (options.content && !options.headers['Content-Type'])
        reqOptions.headers['Content-Type'] = 'application/json';
  
      var request = http.request(reqOptions, function(response) {
        var data = '';
        response.setEncoding('utf8');
        response.on('data', function (chunk) {
          data += chunk;
  
          if (response.headers['content-length'])
            options.progress({loaded : data.length, total : response.headers['content-length'] });
        });
        response.on('end', function() {
          var content = data;
          var ctype = response.headers['content-type'];
  
          if (content && (ctype == 'application/json' || ctype == 'text/json')) {
            try {
              content = JSON.parse(content);
            } catch (e) {}
          }
  
          Util.responseCallback({
            headers:    response.headers,
            content:    content,
            status:     response.statusCode,
            statusText: require('http').STATUS_CODES[response.statusCode]
          }, function(x) { resolver.fulfill(x); }, function(x) { resolver.reject(x); });
        });
      });
  
      if (options.content) {
        request.write(options.headers['Content-Type'] && typeof options.content != 'string' ? JSON.stringify(options.content) : options.content);
      }
  
      request.end();
  
      return resolver.then(options.success, options.failure);
    });
  
    PrecogHttp.get = function(options) {
      return PrecogHttp.http(Util.merge(options, {method: "GET"}));
    };
  
    PrecogHttp.put = function(options) {
      return PrecogHttp.http(Util.merge(options, {method: "PUT"}));
    };
  
    PrecogHttp.post = function(options) {
      return PrecogHttp.http(Util.merge(options, {method: "POST"}));
    };
  
    PrecogHttp.delete0 = function(options) {
      return PrecogHttp.http(Util.merge(options, {method: "DELETE"}));
    };
  
    PrecogHttp.patch = function(options) {
      return PrecogHttp.http(Util.merge(options, {method: "PATCH"}));
    };
  })(PrecogHttp);
  /**
   * Constructs a new Precog client library.
   *
   * @constructor api
   * @memberof precog
   *
   * @param config.apiKey             The API key of the authorizing account. 
   *                                  This is not needed to access the accounts 
   *                                  API methods.
   *
   * @param config.analyticsService   The URL to the analytics service. This is 
   *                                  a required parameter for all API methods.
   *
   */
  function Precog(config) {
    if (!(this instanceof Precog)) return new Precog(config);
    this.config = config;
  }
  
  (function(Precog) {
    var Util = {};
  
    Util.error = function(msg) {
      if (typeof console != 'undefined') console.error(msg);
      throw new Error(msg);
    };
    Util.amap = function(a, f) {
      var ap = [];
      for (var i = 0; i < a.length; i++) {
        ap.push(f(a[i]));
      }
      return ap;
    };
    Util.acontains = function(a, v) {
      for (var i = 0; i < a.length; i++) {
        if (a[i] == v) return true;
      }
      return false;
    };
    Util.requireParam = function(v, name) {
      if (v == null) Util.error('The parameter "' + name + '" may not be null or undefined');
    };
    Util.requireField = function(v, name) {
      if (v == null || v[name] == null) Util.error('The field "' + name + '" may not be null or undefined');
    };
    Util.removeTrailingSlash = function(path) {
      if (path == null || path.length === 0) return path;
      else if (path.substr(path.length - 1) == "/") return path.substr(0, path.length - 1);
      else return path;
    };
    Util.composef = function(f, g) {
      if (!f) return g;
      if (!g) return f;
      else return function(v) {
        return f(g(v));
      };
    };
    Util.parentPath = function(v0) {
      var v = Util.removeTrailingSlash(Util.sanitizePath(v0));
      var elements = v.split('/');
      var sliced = elements.slice(0, elements.length - 1);
      if (!sliced.length) return '/';
      return sliced.join('/');
    };
    Util.lastPathElement = function(v0) {
      var v = Util.sanitizePath(v0);
      var elements = v.split('/');
      if (elements.length === 0) return undefined;
      return elements[elements.length - 1];
    };
    Util.extractField = function(field) { return function(v) { return v[field]; }; };
    Util.extractContent = Util.extractField('content');
    Util.safeCallback = function(f) {
      if (f == null) {
        return function(v) { return v; };
      } else {
        return function(v) {
          var r = f(v);
          if (r === undefined) return v;
          return r;
        };
      }
    };
  
    Util.sanitizePath = function(path) {
      return path.replace(/\/+/g, '/');
    };
    Util.merge = function(o1, o2) {
      var r, key, index;
      if (o1 === undefined) return o1;
      else if (o2 === undefined) return o1;
      else if (o1 instanceof Array && o2 instanceof Array) {
        r = [];
        // Copy
        for (index = 0; index < o1.length; index++) {
          r.push(o1[index]);
        }
        // Merge
        for (index = 0; index < o2.length; index++) {
          if (r.length > index) {
            r[index] = Util.merge(r[index], o2[index]);
          } else {
            r.push(o2[index]);
          }
        }
        return r;
      } else if (o1 instanceof Object && o2 instanceof Object) {
        r = {};
        // Copy:
        for (key in o1) {
          r[key] = o1[key];
        }
        // Merge:
        for (key in o2) {
          if (r[key] !== undefined) {
            r[key] = Util.merge(r[key], o2[key]);
          } else {
            r[key] = o2[key];
          }
        }
        return r;
      } else {
        return o2;
      }
    };
    Util.addCallbacks = function(f) {
      return function(v, success, failure) {
        return f.call(this, v).then(Util.safeCallback(success), failure);
      };
    };
  
    Precog.prototype.serviceUrl = function(serviceName, serviceVersion, path) {
      Util.requireField(this.config, "analyticsService");
  
      return this.config.analyticsService + 
             Util.sanitizePath("/" + serviceName + "/v" + serviceVersion + "/" + (path || ''));
    };
  
    Precog.prototype.accountsUrl = function(path) {
      return this.serviceUrl("accounts", 1, path);
    };
  
    Precog.prototype.securityUrl = function(path) {
      return this.serviceUrl("security", 1, path);
    };
  
    Precog.prototype.dataUrl = function(path) {
      return this.serviceUrl("ingest", 1, path);
    };
  
    Precog.prototype.analysisUrl = function(path) {
      return this.serviceUrl("analytics", 1, path);
    };
  
    Precog.prototype.metadataUrl = function(path) {
      return this.serviceUrl("meta", 1, path);
    };
  
    Precog.prototype.requireConfig = function(name) {
      if (this.config == null || this.config[name] == null) 
        Util.error('The configuration field "' + name + '" may not be null or undefined');
    };
  
    // *************
    // *** ENUMS ***
    // *************
    Precog.GrantTypes = {
      Append:   "append",
      Replace:  "replace",
      Execute:  "execute",
      Mount:    "mount",
      Create:   "create",
      Explore:  "explore"
    };
  
    Precog.FileTypes = {
      JSON:           'application/json',
      JSON_STREAM:    'application/x-json-stream',
      CSV:            'text/csv',
      ZIP:            'application/zip',
      GZIP:           'application/x-gzip',
      QUIRREL_SCRIPT: 'text/x-quirrel-script'
    };
  
    // ****************
    // *** ACCOUNTS ***
    // ****************
  
    /**
     * Creates a new account with the specified email and password. In order for 
     * this function to succeed, the specified email cannot already be associated
     * with an account.
     *
     * @method createAccount
     * @memberof precog.api.prototype
     * @example
     * Precog.createAccount({email: "jdoe@foo.com", password: "abc123"});
     */
    Precog.prototype.createAccount = Util.addCallbacks(function(account) {
      var self = this;
  
      Util.requireField(account, 'email');
      Util.requireField(account, 'password');
  
      return PrecogHttp.post({
        url:      self.accountsUrl("accounts/"),
        content:  account,
        success:  Util.extractContent
      });
    });
  
    /**
     * Requests a password reset for the specified email. This may or may not have
     * any effect depending on security settings.
     *
     * @method requestPasswordReset
     * @memberof precog.api.prototype
     * @example
     * Precog.requestPasswordReset('jdoe@foo.com');
     */
    Precog.prototype.requestPasswordReset = Util.addCallbacks(function(email) {
      var self = this;
  
      Util.requireParam(email, 'email');
  
      return self.lookupAccountId(email).then(function(result) {
        return PrecogHttp.post({
          url:      self.accountsUrl("accounts") + "/" + result.accountId + "/password/reset",
          content:  {email: email},
          success:  Util.extractContent
        });
      });
    });
  
    /**
     * Looks up the account associated with the specified email address.
     *
     * @method lookupAccountId
     * @memberof precog.api.prototype
     * @example
     * Precog.lookupAccountId('jdoe@foo.com');
     */
    Precog.prototype.lookupAccountId = Util.addCallbacks(function(email) {
      var self = this;
      var resolver = Vow.promise();
  
      Util.requireParam(email, 'email');
  
      PrecogHttp.get({
        url:      self.accountsUrl("accounts/search"),
        query:    {email: email},
        success:  function(response) {
          var accounts = response.content;
  
          if (!accounts || accounts.length === 0) {
            resolver.reject({status: 400, statusText: 'No account ID found for given email'});
          } else {
            resolver.fulfill(accounts[0]);
          }
        },
        failure: resolver.reject
      });
  
      return resolver;
    });
  
    /**
     * Describes the specified account, identified by email and password.
     *
     * @method describeAccount
     * @memberof precog.api.prototype
     * @example
     * Precog.describeAccount({email: 'jdoe@foo.com', password: 'abc123'});
     */
    Precog.prototype.describeAccount = Util.addCallbacks(function(account) {
      var self = this;
  
      Util.requireField(account, 'email');
      Util.requireField(account, 'password');
  
      return self.lookupAccountId(account.email).then(function(response) {
        return PrecogHttp.get({
          basicAuth: {
            username: account.email,
            password: account.password
          },
          url:      self.accountsUrl("accounts/" + response.accountId),
          success:  Util.extractContent
        });
      });
    });
  
    /**
     * Adds a grant to the specified account.
     *
     * @method addGrantToAccount
     * @memberof precog.api.prototype
     * @example
     * Precog.addGrantToAccount(
     *   {accountId: '23987123', grantId: '0d43eece-7abb-43bd-8385-e33bac78e145'}
     * );
     */
    Precog.prototype.addGrantToAccount = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'accountId');
      Util.requireField(info, 'grantId');
  
      return PrecogHttp.post({
        url:      self.accountsUrl("accounts/" + info.accountId + "/grants/"),
        content:  {grantId: info.grantId},
        success:  Util.extractContent
      });
    });
  
    /**
     * Retrieves the plan that the specified account is on. The account is 
     * identified by email and password.
     *
     * @method currentPlan
     * @memberof precog.api.prototype
     * @example
     * Precog.currentPlan({email: 'jdoe@foo.com', password: 'abc123'});
     */
    Precog.prototype.currentPlan = Util.addCallbacks(function(account) {
      var self = this;
  
      Util.requireField(account, 'email');
      Util.requireField(account, 'password');
  
      return self.lookupAccountId(account.email).then(function(response) {
        return PrecogHttp.get({
          basicAuth: {
            username: account.email,
            password: account.password
          },
          url:     self.accountsUrl("accounts/" + response.accountId + "/plan"),
          success: Util.composef(Util.extractField('type'), Util.extractContent)
        });
      });
    });
  
    /**
     * Changes the account's plan.
     *
     * @method changePlan
     * @memberof precog.api.prototype
     * @example
     * Precog.changePlan({email: 'jdoe@foo.com', password: 'abc123', plan: 'BRONZE'});
     */
    Precog.prototype.changePlan = Util.addCallbacks(function(account) {
      var self = this;
  
      Util.requireField(account, 'email');
      Util.requireField(account, 'password');
      Util.requireField(account, 'plan');
  
      return self.lookupAccountId(account.email).then(function(response) {
        return PrecogHttp.put({
          basicAuth: {
            username: account.email,
            password: account.password
          },
          url:      self.accountsUrl("accounts/" + response.accountId + "/plan"),
          content:  {type: account.plan},
          success:  Util.extractContent
        });
      });
    });
  
    /**
     * Delete's the account's plan, resetting it to the default plan on the system.
     *
     * @method deletePlan
     * @memberof precog.api.prototype
     * @example
     * Precog.deletePlan({email: 'jdoe@foo.com', password: 'abc123'});
     */
    Precog.prototype.deletePlan = Util.addCallbacks(function(account) {
      var self = this;
  
      Util.requireField(account, 'email');
      Util.requireField(account, 'password');
  
      return self.lookupAccountId(account.email).then(function(response) {
        return PrecogHttp.delete0({
          basicAuth: {
            username: account.email,
            password: account.password
          },
          url:      self.accountsUrl("accounts/" + response.accountId + "/plan"),
          success:  Util.composef(Util.extractField('type'), Util.extractContent)
        });
      });
    });
  
    // ****************
    // *** SECURITY ***
    // ****************
  
    /**
     * Lists API keys.
     *
     * @method listApiKeys
     * @memberof precog.api.prototype
     * @example
     * Precog.listApiKeys();
     */
    Precog.prototype.listApiKeys = function(success, failure) {
      var self = this;
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.securityUrl("apikeys/"),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      }).then(Util.safeCallback(success), failure);
    };
  
    /**
     * Creates a new API key with the specified grants.
     *
     * @method createApiKey
     * @memberof precog.api.prototype
     * @example
     * Precog.createApiKey(grants);
     */
    Precog.prototype.createApiKey = Util.addCallbacks(function(grants) {
      var self = this;
  
      Util.requireParam(grants, 'grants');
      self.requireConfig('apiKey');
  
      return PrecogHttp.post({
        url:      self.securityUrl("apikeys/"),
        content:  grants,
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Describes an existing API key.
     *
     * @method describeApiKey
     * @memberof precog.api.prototype
     * @example
     * Precog.describeApiKey('475ae23d-f5f9-4ffc-b643-e805413d2233');
     */
    Precog.prototype.describeApiKey = Util.addCallbacks(function(apiKey) {
      var self = this;
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.securityUrl("apikeys/" + apiKey),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Deletes an existing API key.
     *
     * @method deleteApiKey
     * @memberof precog.api.prototype
     * @example
     * Precog.deleteApiKey('475ae23d-f5f9-4ffc-b643-e805413d2233');
     */
    Precog.prototype.deleteApiKey = Util.addCallbacks(function(apiKey) {
      var self = this;
  
      Util.requireParam(apiKey, 'apiKey');
      self.requireConfig('apiKey');
  
      return PrecogHttp.delete0({
        url:      self.securityUrl("apikeys/" + apiKey),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Retrieves the grants associated with an existing API key.
     *
     * @method retrieveApiKeyGrants
     * @memberof precog.api.prototype
     * @example
     * Precog.retrieveApiKeyGrants('475ae23d-f5f9-4ffc-b643-e805413d2233');
     */
    Precog.prototype.retrieveApiKeyGrants = Util.addCallbacks(function(apiKey) {
      var self = this;
  
      Util.requireParam(apiKey, 'apiKey');
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.securityUrl("apikeys/" + apiKey + "/grants/"),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Adds a grant to an existing API key.
     *
     * @method addGrantToApiKey
     * @memberof precog.api.prototype
     * @example
     * Precog.createApiKey({grant: grant, apiKey: apiKey});
     */
    Precog.prototype.addGrantToApiKey = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'grant');
      Util.requireField(info, 'apiKey');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.post({
        url:      self.securityUrl("apikeys/" + info.apiKey + "/grants/"),
        content:  info.grant,
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Removes a grant from an existing API key.
     *
     * @method removeGrantFromApiKey
     * @memberof precog.api.prototype
     * @example
     * Precog.removeGrantFromApiKey({
     *   apiKey: '475ae23d-f5f9-4ffc-b643-e805413d2233', 
     *   grantId: '0b47db0d-ed14-4b56-831b-76b8bf66f976'
     * });
     */
    Precog.prototype.removeGrantFromApiKey = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'grantId');
      Util.requireField(info, 'apiKey');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.delete0({
        url:      self.securityUrl("apikeys/" + info.apiKey + "/grants/" + info.grantId),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Creates a new grant.
     *
     * @method createGrant
     * @memberof precog.api.prototype
     * @example
     * Precog.createGrant({
     *   "name": "",
     *   "description": "",
     *   "parentIds": "",
     *   "expirationDate": "",
     *   "permissions" : [{
     *     "accessType": "read",
     *     "path": "/foo/",
     *     "ownerAccountIds": "[Owner Account Id]"
     *   }]
     * });
     */
    Precog.prototype.createGrant = Util.addCallbacks(function(grant) {
      var self = this;
  
      Util.requireParam(grant, 'grant');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.post({
        url:      self.securityUrl("grants/"),
        content:  grant,
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Describes an existing grant.
     *
     * @method describeGrant
     * @memberof precog.api.prototype
     * @example
     * Precog.describeGrant('581c36a6-0e14-487e-8622-3a38b828b931');
     */
    Precog.prototype.describeGrant = Util.addCallbacks(function(grantId) {
      var self = this;
  
      Util.requireParam(grantId, 'grantId');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.securityUrl("grants/" + grantId),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Deletes an existing grant. In order for this operation to succeed,
     * the grant must have been created by the authorizing API key.
     *
     * @method deleteGrant
     * @memberof precog.api.prototype
     * @example
     * Precog.deleteGrant('581c36a6-0e14-487e-8622-3a38b828b931');
     */
    Precog.prototype.deleteGrant = Util.addCallbacks(function(grantId) {
      var self = this;
  
      Util.requireParam(grantId, 'grantId');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.delete0({
        url:      self.securityUrl("grants/" + grantId),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Lists the children of an existing grant.
     *
     * @method listGrantChildren
     * @memberof precog.api.prototype
     * @example
     * Precog.listGrantChildren('581c36a6-0e14-487e-8622-3a38b828b931');
     */
    Precog.prototype.listGrantChildren = Util.addCallbacks(function(grantId) {
      var self = this;
  
      Util.requireParam(grantId, 'grantId');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.securityUrl("grants/" + grantId + "/children/"),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Lists the children of an existing grant.
     *
     * @method createGrantChild
     * @memberof precog.api.prototype
     * @example
     * Precog.createGrantChild({
     *   parentGrantId: '581c36a6-0e14-487e-8622-3a38b828b931', 
     *   childGrant: childGrant
     * });
     */
    Precog.prototype.createGrantChild = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'parentGrantId');
      Util.requireField(info, 'childGrant');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.post({
        url:      self.securityUrl("grants/" + info.parentGrantId + "/children/"),
        content:  info.childGrant,
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    // ****************
    // *** METADATA ***
    // ****************
  
  
    Precog.prototype._retrieveMetadata = Util.addCallbacks(function(path) {
      var self = this;
  
      Util.requireParam(path, 'path');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.metadataUrl("fs/" + path),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    Precog.prototype._uniqueHash = function() {
      var self = this;
  
      var hashCode = function(str){
        var hash = 0;
        if (str.length === 0) return hash;
        for (var i = 0; i < str.length; i++) {
          var chr = str.charCodeAt(i);
          hash = ((hash<<5)-hash) + chr;
          hash = hash & hash;
        }
        return hash;
      };
  
      self.requireConfig('apiKey');
  
      return hashCode('Precog' + self.config.apiKey);
    };
  
    Precog.prototype._localStorageKey = function(key) {
      return this._uniqueHash() + key;
    };
  
    Precog.prototype._isEmulateData = function(path0) {
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      if (typeof localStorage !== 'undefined') {
        var path = Util.sanitizePath(path0);
  
        return localStorage.getItem(self._localStorageKey(path)) != null;
      }
  
      return false;
    };
  
    Precog.prototype._getEmulateData = function(path0) {
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      var data = {};
      if (typeof localStorage !== 'undefined') {
        var path = Util.sanitizePath(path0);
  
        data = JSON.parse(localStorage.getItem(self._localStorageKey(path)) || '{}');
      } else {
        if (console && console.error) console.error('Missing local storage!');
      }
  
      return data;
    };
  
    Precog.prototype._deleteEmulateData = function(path0) {
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      if (typeof localStorage !== 'undefined') {
        var path = Util.sanitizePath(path0);
  
        localStorage.removeItem(self._localStorageKey(path));
      } else {
        if (console && console.error) console.error('Missing local storage!');
      }
    };
  
    Precog.prototype._setEmulateData = function(path0, data) {
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      if (typeof localStorage !== 'undefined') {
        var path = Util.sanitizePath(path0);
  
        localStorage.setItem(self._localStorageKey(path), JSON.stringify(data));
      } else {
        if (console && console.error) console.error('Missing local storage!');
      }
    };
  
    Precog.prototype._getChildren = function(path0) {
      var self = this;
  
      var children = [];
      var key;
      var relative;
      var filename;
  
      if (typeof localStorage !== 'undefined') {
        var path = Util.sanitizePath(path0);
  
        for (key in localStorage) {
          if (key.indexOf(self._localStorageKey(path))) continue;
          relative = key.substr((self._localStorageKey(path)).length);
          filename = relative.substr(0, relative.indexOf('/') == -1 ? relative.length : relative.indexOf('/'));
          if (!filename || children.indexOf(filename) != -1) continue;
          children.push(filename);
        }
      } else {
        if (console && console.error) console.error('Missing local storage!');
      }
  
      return children;
    };
  
    Precog.prototype._getTypedChildren = function(path0) {
      var children = this._getChildren(path0);
      var typedChildren = [];
      var i;
      var path = Util.sanitizePath(path0 + '/');
  
      for (i = 0; i < children.length; i++) {
        typedChildren.push({
          name: children[i],
          type: this._getChildren(path + children[i] + '/').length ? 'directory' : 'file'
        });
      }
  
      return typedChildren;
    };
  
    /**
     * Retrieves metadata for the specified path.
     *
     * @method getMetadata
     * @memberof precog.api.prototype
     * @example
     * Precog.getMetadata('/foo');
     */
    Precog.prototype.getMetadata = Util.addCallbacks(function(path) {
      // FIXME: EMULATION
      var self = this;
  
      Util.requireParam(path, 'path');
  
      self.requireConfig('apiKey');
  
      return self.listChildren(path).then(function(children) {
        return self.getNodeType(path).then(function(nodeType) {
          var metadata = {};
  
          if (Util.acontains(nodeType, 'directory')) {
            metadata.defaultFiles = {
              'text/x-quirrel-script': 'index.qrl',
              'text/html': 'index.html'
            };
  
            metadata.children = children;
          }
  
          if (Util.acontains(nodeType, 'file')) {
            if (self._isEmulateData(path)) {
              var data = self._getEmulateData(path);
  
              metadata.type = data.type;
            } else {
              metadata.type = 'application/json';
            }
          }
  
          return metadata;
        });
      });
      // END EMULATION
    });
  
    /**
     * Retrieves the type of a node in the file system, whether file or directory.
     *
     * @method getNodeType
     * @memberof precog.api.prototype
     * @example
     * Precog.getNodeType('/foo/bar');
     */
    Precog.prototype.getNodeType = Util.addCallbacks(function(path0) {
      // FIXME: EMULATION
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      self.requireConfig('apiKey');
  
      var path = Util.sanitizePath(path0);
  
      var countPath = function(path) {
        return self.execute({query: 'count(load("' + path + '"))'}).then(function(results) {
          return results.data && results.data[0] || 0;
        });
      };
  
      var listRawChildren = function(path) {
        return self._retrieveMetadata(path).then(function(metadata) {
          return metadata.children;
        });
      };
  
      return listRawChildren(path).then(function(children) {
        return countPath(path).then(function(count) {
          var types = [];
  
          if (children.length > 0) types.push('directory');
          if (count > 0 || self._isEmulateData(path)) types.push('file');
  
          return types;
        });
      });
      // END EMULATION
    });
  
    /**
     * Retrieves all children of the specified path.
     *
     * @method listChildren
     * @memberof precog.api.prototype
     * @example
     * Precog.listChildren('/foo');
     */
    Precog.prototype.listChildren = Util.addCallbacks(function(path) {
      var self = this;
  
      Util.requireParam(path, 'path');
  
      var extraChildren = self._getTypedChildren(path);
      
      return this._retrieveMetadata(path).then(function(metadata) {
        var childNames = metadata.children || [];
  
        return Vow.all(Util.amap(childNames, function(childName) {
          return self.getNodeType(path + '/' + childName);
        })).then(function(childTypes) {
          var flattened = [];
          var slashlessNames = [];
          var i;
          var name;
  
          for (i = 0; i < childNames.length; i++) {
            name = Util.removeTrailingSlash(childNames[i]);
            slashlessNames.push(name);
            var types = childTypes[i];
  
            for (var j = 0; j < types.length; j++) {
              var type = types[j];
  
              flattened.push({
                type: type,
                name: name
              });
            }
          }
  
          for (i = 0; i < extraChildren.length; i++) {
            name = Util.removeTrailingSlash(extraChildren[i].name);
            if (slashlessNames.indexOf(name) != -1) continue;
            flattened.push({
              name: name,
              type: extraChildren[i].type
            });
          }
  
          return flattened;
        });
      });
      // END EMULATION
    });
  
    /**
     * Retrieves all descendants of the specified path.
     *
     * @method listDescendants
     * @memberof precog.api.prototype
     * @example
     * Precog.listDescendants('/foo');
     */
    Precog.prototype.listDescendants = Util.addCallbacks(function(path0) {
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      var path = Util.sanitizePath(path0 + '/');
  
      function listDescendants0(root, prefix) {
        return self.listChildren(root).then(function(children) {
  
          var absolutePaths0 = Util.amap(children, function(child) {
            if (child.name === '/' || child.name === '') Util.error('Infinite recursion');
  
            return Util.sanitizePath(root + '/' + child.name);
          });
  
          var absolutePaths = [];
  
          Util.amap(absolutePaths0, function(path) {
            if (!Util.acontains(absolutePaths, path)) {
              absolutePaths.push(path);
            }
          });
  
          var relativePaths = Util.amap(absolutePaths, function(absolute) {
            // Always return path relative to prefix:
            return absolute.substr(prefix.length);
          });
  
          var futures = Util.amap(absolutePaths, function(absolute) {
            return listDescendants0(absolute, prefix);
          });
  
          return Vow.all(futures).then(function(arrays) {          
            return [].concat.apply(relativePaths, arrays);
          });
        });
      }
  
      return listDescendants0(path, path);
    });
  
    /**
     * Determines if the specified file exists.
     *
     * @method existsFile
     * @memberof precog.api.prototype
     * @example
     * Precog.existsFile('/foo/bar.json');
     */
    Precog.prototype.existsFile = Util.addCallbacks(function(path) {
      var self = this;
  
      Util.requireParam(path, 'path');
  
      var targetDir  = Util.parentPath(path);
      var targetName = Util.lastPathElement(path);
  
      if (targetName === '') Util.error('To determine if a file exists, the file name must be specified');
  
      return self.listChildren(targetDir).then(function(children0) {
        var names = Util.amap(children0, function(child) { return child.name; });
  
        return Util.acontains(names, targetName);
      });
    });
  
    // ************
    // *** DATA ***
    // ************
  
    /**
     * Uploads the specified contents to the specified path, using the specified
     * file type (which must be a mime-type accepted by the server).
     *
     * @method uploadFile
     * @memberof precog.api.prototype
     * @example
     * Precog.uploadFile({path: '/foo/bar.csv', type: Precog.FileTypes.CSV, contents: contents});
     */
    Precog.prototype.uploadFile = Util.addCallbacks(function(info) {
      var self = this;
      var resolver;
  
      Util.requireField(info, 'path');
      Util.requireField(info, 'type');
      Util.requireField(info, 'contents');
  
      self.requireConfig('apiKey');
  
      if (typeof info.contents !== 'string') Util.error('File contents must be a string');
  
      var targetDir  = Util.parentPath(info.path);
      var targetName = Util.lastPathElement(info.path);
  
      if (targetName === '') Util.error('A file may only be uploaded to a specific directory');
  
      var fullPath = targetDir + '/' + targetName;
  
      // FIXME: EMULATION
      var emulate;
  
      switch (info.type) {
        case Precog.FileTypes.JSON:
        case Precog.FileTypes.JSON_STREAM:
        case Precog.FileTypes.CSV:
        case Precog.FileTypes.ZIP:
        case Precog.FileTypes.GZIP:
  
          emulate = false;
        break;
  
        default: 
          emulate = true;
  
        break;
      }
  
      if (emulate) {
        // Keep track of the contents & type of this file:
        var fileNode = self._getEmulateData(fullPath);
  
        fileNode.type     = info.type;
        fileNode.contents = info.contents;
        fileNode.version  = fileNode.version ? fileNode.version + 1 : 1;
        fileNode.lastModified = new Date().getTime();
  
        self._setEmulateData(fullPath, fileNode);
  
        if (info.type === 'text/x-quirrel-script') {
          // The file is a script, immediately execute it:
          return self.executeFile({
            path: fullPath
          }).then(function(results) {
            // Take the data, and upload it to the file system.
            return self.uploadFile({
              path:     fullPath,
              type:     'application/json',
              contents: JSON.stringify(results.data),
              saveEmulation: true // Don't delete the emulation data
            });
          }).then(function() {
            return {versions: {head: fileNode.version}};
          });
        } else {
          // The file is not a script, so we can't execute it, so just
          // report success:
          resolver = Vow.promise();
          resolver.fulfill({versions:{head: fileNode.version}});
          return resolver;
        }
  
        // END EMULATION
      } else {
        var doUpload = function() {
          return PrecogHttp.post({
            url:      self.dataUrl((info.async ? "async" : "sync") + "/fs/" + fullPath),
            content:  info.contents,
            query:    {
              apiKey:         self.config.apiKey,
              ownerAccountId: info.ownerAccountId,
              delimiter:      info.delimiter,
              quote:          info.quote,
              escape:         info.escape
            },
            headers:  { 'Content-Type': info.type },
            success: Util.extractContent
          });
        };
  
        // First delete data, then upload!
        return PrecogHttp.delete0({
          url:      self.dataUrl("async/fs/" + fullPath),
          query:    {apiKey: self.config.apiKey},
          success:  Util.extractContent
        }).then(doUpload, doUpload);
      }
    });
  
    /**
     * Creates the specified file. The file must not already exist.
     *
     * @method createFile
     * @memberof precog.api.prototype
     * @example
     * Precog.createFile({path: '/foo/bar.csv', type: Precog.FileTypes.CSV, contents: contents});
     */
    Precog.prototype.createFile = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'path');
      Util.requireField(info, 'type');
      Util.requireFiled(info, 'contents');
  
      return self.existsFile(info.path).then(function(fileExists) {
        if (!fileExists) {
          return self.uploadFile(info);
        } else Util.error('The file ' + info.path + ' already exists');
      });
    });
  
    /**
     * Retrieves the contents of the specified file.
     *
     * @method getFile
     * @memberof precog.api.prototype
     * @example
     * Precog.getFile('/foo/bar.qrl');
     */
    Precog.prototype.getFile = Util.addCallbacks(function(path) {
      var self = this;
  
      Util.requireParam(path, 'path');
  
      // FIXME: EMULATION
      if (self._isEmulateData(path)) {
        var fileNode = self._getEmulateData(path);
        var resolver = Vow.promise();
        resolver.fulfill({
          contents: fileNode.contents, 
          type:     fileNode.type
        });
  
        return resolver;
      } else {
        return self.execute({query: 'load("' + path + '")'}).then(function(results) {
          return {
            contents: JSON.stringify(results.data),
            type:    'application/json'
          };
        });
      }
      // END EMULATION
    });
  
    /**
     * Appends a single JSON value to the specified data file.
     *
     * @method append
     * @memberof precog.api.prototype
     * @example
     * Precog.append({path: '/website/clicks.json', value: clickEvent});
     */
    Precog.prototype.append = Util.addCallbacks(function(info) {
      info.values = [info.value];
  
      delete info.value;
  
      return this.appendAll(info);
    });
  
    /**
     * Appends a collection of JSON values to the specified file.
     *
     * @method appendAll
     * @memberof precog.api.prototype
     * @example
     * Precog.append({path: '/website/clicks.json', values: clickEvents});
     */
    Precog.prototype.appendAll = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'values');
      Util.requireField(info, 'path');
  
      self.requireConfig('apiKey');
  
      var targetDir  = Util.parentPath(info.path);
      var targetName = Util.lastPathElement(info.path);
  
      if (targetName === '') Util.error('Data must be appended to a specific file.');
  
      var fullPath = targetDir + '/' + targetName;
  
      return PrecogHttp.post({
        url:      self.dataUrl(info.async ? "async" : "sync") + "/fs/" + fullPath,
        content:  info.values,
        query:    {
                    apiKey:         self.config.apiKey,
                    ownerAccountId: info.ownerAccountId
                  },
        success:  Util.extractContent
      });
    });
  
    /**
     * Deletes a specified file in the Precog file system.
     *
     * @method delete0
     * @memberof precog.api.prototype
     * @example
     * Precog.delete0('/website/clicks.json');
     */
    Precog.prototype.delete0 = Util.addCallbacks(function(path) {
      var self = this;
  
      Util.requireParam(path, 'path');
  
      self.requireConfig('apiKey');
  
      self._deleteEmulateData(path);
  
      return PrecogHttp.delete0({
        url:      self.dataUrl("async/fs/" + path),
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  
    /**
     * Deletes the specified directory and everything it contains.
     *
     * @method deleteAll
     * @memberof precog.api.prototype
     * @example
     * Precog.deleteAll('/website/');
     */
    Precog.prototype.deleteAll = Util.addCallbacks(function(path0) {
      var self = this;
  
      Util.requireParam(path0, 'path');
  
      self.requireConfig('apiKey');
  
      var path = Util.sanitizePath(path0);
  
      return self.listDescendants(path).then(function(descendants) {
        // Convert relative paths to absolute paths:
        var absolutePaths = (Util.amap(descendants, function(child) {
          return Util.sanitizePath(path + '/' + child);
        })).concat([path]);
  
        return Vow.all(Util.amap(absolutePaths, function(child) {
          return self.delete0(child);
        }));
      });
    });
  
    /**
     * Copies a file from specified source to specified destination.
     *
     * @method copyFile
     * @memberof precog.api.prototype
     * @example
     * Precog.copyFile({source: '/foo/v1.qrl', dest: '/foo/v2.qrl'})
     */
    Precog.prototype.copyFile = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'source');
      Util.requireField(info, 'dest');
  
      return self.getFile(info.source).then(function(file) {
        return self.uploadFile({
          path:     info.dest,
          type:     file.type,
          contents: file.contents
        });
      });
    });
  
    /**
     * Moves a file from one location to another.
     *
     * @method moveFile
     * @memberof precog.api.prototype
     * @example
     * Precog.moveFile({source: '/foo/helloo.qrl', dest: '/foo/hello.qrl'})
     */
    Precog.prototype.moveFile = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'source');
      Util.requireField(info, 'dest');
  
      return self.copyFile(info).then(function() {
        return self.delete0(info.source);
      });
    });
  
    /**
     * Moves a directory and its contents from one location to another.
     *
     * @method moveDirectory
     * @memberof precog.api.prototype
     * @example
     * Precog.moveDirectory({source: '/foo/helloo', dest: '/foo/hello'})
     */
    Precog.prototype.moveDirectory = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'source');
      Util.requireField(info, 'dest');
  
      return self.listDescendants(info.source).then(function(descendants) {
        var resolvers = [];
  
        // Copy each file
        for (var i = 0; i < descendants.length; i++) {
          var absSource = info.source + '/' + descendants[i];
          var absDest   = info.dest   + '/' + descendants[i];
  
          resolvers.push(self.copyFile({
            source: absSource,
            dest:   absDest
          }));
        }
  
        return Vow.all(resolvers).then(function() {
          return self.deleteAll(info.source);
        });
      });
    });
  
    // ****************
    // *** ANALYSIS ***
    // ****************
  
    /**
     * Executes the specified file, which must be a Quirrel script. The
     * maxAge and maxStale settings can be used to accept older analyses.
     *
     * @method executeFile
     * @memberof precog.api.prototype
     * @example
     * Precog.executeFile({path: '/foo/script.qrl'});
     */
    Precog.prototype.executeFile = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'path');
  
      // FIXME: EMULATION
      if (self._isEmulateData(info.path) && info.maxAge) {
        // User wants to cache, see if there's a cached version:
        var fileNode = self._getEmulateData(info.path);
  
        if (fileNode.cached) {
          var cached = fileNode.cached;
  
          // There's a cached version, see if it's fresh enough:
          var now = (new Date()).getTime() / 1000;
  
          var age = now - cached.timestamp;
  
          if (age < info.maxAge || info.maxStale && (age < (info.maxAge + info.maxStale))) {
            var resolver = Vow.promise();
            resolver.fulfill(cached.results);
            return resolver;
          }
        }
      }
      // END EMULATION
  
      // FIXME: EMULATION
  
      // Pull back the contents of the file:
      return self.getFile(info.path).then(function(file) {
        var scriptDir = Util.parentPath(info.path);
  
        // See if the file is executable:
        if (file.type === 'text/x-quirrel-script') {
          var path1 = Util.sanitizePath('/' + scriptDir + '/');
          var path2 = path1.split('/').join('//');
  
          // /./
          // "./
  
          // FIXME: HORRIBLE HACK FOR RELATIVE PATHS!!!! THE HORROR!!!!
          var query2 = file.contents.split('/./').join(path2).split('"./').join('"' + path1);
  
          var executeRequest = {
            query: query2 // file.contents
          };
  
          // Execute the script:
          return self.execute(executeRequest).then(function(results) {
            if (typeof localStorage !== 'undefined') {
              // If there are no errors, store the cached execution of the script:
              if (results && (results.errors == null || results.errors.length === 0)) {
                var fileNode = self._getEmulateData(info.path);
  
                fileNode.cached = {
                  results:   results,
                  timestamp: (new Date()).getTime() / 1000
                };
  
                self._setEmulateData(info.path, fileNode);
              }
            }
  
            return results;
          });
        } else {
          Util.error('The file ' + info.path +
                     ' does not have type text/x-quirrel-script and therefore cannot be executed');
        }
      });
  
      // END EMULATION
    });
  
    /**
     * Executes the specified Quirrel query.
     *
     * Optionally, a 'path' field may be specified which uses that path as
     * the base path.
     *
     * Returns {"data": ..., "errors": ..., "warnings": ...}
     *
     * @method execute
     * @memberof precog.api.prototype
     * @example
     * Precog.execute({query: 'count(//foo)'});
     */
    Precog.prototype.execute = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'query');
  
      self.requireConfig('apiKey');
  
      return PrecogHttp.get({
        url:      self.analysisUrl("fs/" + (info.path || '')),
        query:    {
                    apiKey: self.config.apiKey, 
                    q:      info.query,
                    limit:  info.limit,
                    skip:   info.skip,
                    sortOn: info.sortOn,
                    format: 'detailed'
                  },
        success:  Util.extractContent
      });
    });
  
    /**
     * Submits a Quirrel query and gives a job identifier back. Use
     * asyncQueryResults to poll for results.
     *
     * @method _asyncQuery
     * @memberof precog.api.prototype
     * @example
     * Precog._asyncQuery({query: '1 + 4'});
     */
    Precog.prototype._asyncQuery = Util.addCallbacks(function(info) {
      var self = this;
  
      Util.requireField(info, 'query');
  
      return PrecogHttp.post({
        url:      self.analysisUrl("queries"),
        query:    {
                    apiKey     : self.config.apiKey,
                    q          : info.query,
                    limit      : info.limit,
                    basePath   : info.path,
                    skip       : info.skip,
                    order      : info.order,
                    sortOn     : info.sortOn,
                    sortOrder  : info.sortOrder,
                    timeout    : info.timeout,
                    prefixPath : info.prefixPath,
                    format     : info.format
                  },
        success:  Util.extractContent
      });
    });
  
    /**
     * Poll the status of the specified query job.
     *
     * @method _asyncQueryResults
     * @memberof precog.api.prototype
     * @example
     * Precog._asyncQueryResults('8837ee1674fb478fb2ebb0b521eaa6ce');
     */
    Precog.prototype._asyncQueryResults = Util.addCallbacks(function(jobId) {
      var self = this;
  
      Util.requireParam(jobId, 'jobId');
  
      return PrecogHttp.get({
        url:      self.analysisUrl("queries/") + jobId,
        query:    {apiKey: self.config.apiKey},
        success:  Util.extractContent
      });
    });
  })(Precog);

  return {
    http: PrecogHttp,
    api:  Precog
  };
});