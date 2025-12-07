// ==UserScript==
// @name         Fanfox navigation
// @namespace    96dbb15bc0a5496c49afa4987a8d1d2c4935099f50ddb13f292449f58f752bdd
// @version      0.1
// @description  Forces usage of the desktop layout for /releases/* and mobile layout for /manga/*
// @author       /u/jumapico
// @match        https://fanfox.net/manga/*
// @match        https://newm.fanfox.net/releases/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
        'use strict';
        if (location.pathname.includes("/releases/")) {
                if (location.hostname != "fanfox.net") {
                        location.hostname = "fanfox.net";
                }
        } else if (location.pathname.includes("/manga/")) {
                if (location.hostname != "newm.fanfox.net") {
                        location.hostname = "newm.fanfox.net";
                }
        }
})();

/*
LICENSE:
This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
The full license text can be found here: http://creativecommons.org/licenses/by-nc-sa/4.0/
The link has an easy to understand version of the license and the full license text.

DISCLAIMER:
THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
*/
