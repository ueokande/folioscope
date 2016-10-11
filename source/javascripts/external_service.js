'use strict';

var link = location.hash.slice(1);
var a = document.getElementById('title');
a.textContent = link;
a.href = "https://github.com/" + link;
