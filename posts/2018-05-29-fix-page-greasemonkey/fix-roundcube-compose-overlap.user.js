// ==UserScript==
// @name        fix-roundcube-compose-overlap
// @namespace   jumapico.uy/greasemonkey
// @version     1
// @grant       none
// @match       *://*/webmail/?*_task=mail*_action=compose*
// @description Fix overlapping issue when compose email in roundcube webmail
// ==/UserScript==

function insert_style(css) {
    var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style');
    style.type = 'text/css';
    style.appendChild(document.createTextNode(css));
    head.appendChild(style);
}

insert_style('#compose-body { margin-top: 3em; }');
