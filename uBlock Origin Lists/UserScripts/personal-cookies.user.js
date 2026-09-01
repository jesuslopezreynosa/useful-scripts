// ==UserScript==
// @name         JLR - Cookie & LocalStorage Injector - Personal Settings / Privacy Preferences
// @namespace    https://github.com/jesuslopezreynosa/useful-scripts
// @match        *://*.duckduckgo.com/*
// @match        *://*.qwant.com/*
// @match        *://*.brave.com/*
// @match        *://*.ecosia.org/*
// @match        *://*.startpage.com/*
// @match        *://*.wikipedia.org/*
// @match        *://*.britannica.com/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    const host = window.location.hostname;
    const common = "; path=/; Max-Age=31536000; SameSite=Lax";

    const safeSetLocalStorage = (key, value) => {
        try {
            window.localStorage.setItem(key, value);
        } catch (e) {
            // Silence DOMException if storage is restricted
        }
    };

    if (host.includes('duckduckgo.com')) {
        const ddgDom = "; domain=.duckduckgo.com" + common;

        // Cookies
        document.cookie = "1=-1" + ddgDom;
        document.cookie = "aj=u" + ddgDom;
        document.cookie = "ak=-1" + ddgDom;
        document.cookie = "ao=-1" + ddgDom;
        document.cookie = "ap=-1" + ddgDom;
        document.cookie = "aq=-1" + ddgDom;
        document.cookie = "at=-1" + ddgDom;
        document.cookie = "au=-1" + ddgDom;
        document.cookie = "ax=-1" + ddgDom;
        document.cookie = "ax=v433-5" + ddgDom;
        document.cookie = "be=1" + ddgDom;
        document.cookie = "bj=1" + ddgDom;
        document.cookie = "k=-1" + ddgDom;
        document.cookie = "psb=-1" + ddgDom;

        // Local Storage
        const ddg_settings = { "k1": "-1", "kaj": "u", "kak": "-1", "kao": "-1", "kap": "-1", "kaq": "-1", "kau": "-1", "kax": "v433-5", "kbj": "1", "kpsb": "-1", "kbe": "1", "kk": "-1", "kbm": "foxnews.com,foxnation.com,radio.foxnews.com,foxbusiness.com,quora.com,tiktok.com,yahoo.com,answers.com,bbb.org,klarna.com,sourceforge.net,sky.com,nypost.com,huffpost.com,metro.co.uk,dailymail.co.uk,tmz.com,rt.com,cjr.org,prageru.com,reason.com,theblaze.com,thedailybeast.com,perezhilton.com,ew.com,news.google.com,go.com,msn.com,cnn.com,usnews.com,newsmax.com,newsmax.org,eonline.com,usatoday.com,bbc.com,x.com,x.ai,grok.com,twitter.com,facebook.com,fb.com,meta.com,truthsocial.com,pinterest.com,news.google.com,news.yahoo.com,aol.com,bing.com,cnbc.com,msnbc.com,tiktok.com,nbcwashington.com" };
        safeSetLocalStorage('duckaiHasAgreedToTerms', 'true');
        safeSetLocalStorage('duckduckgo_settings', JSON.stringify(ddg_settings));
    }

    if (host.includes('brave.com')) {
        const brDom = "; domain=.brave.com" + common;
        document.cookie = "codellm=0" + brDom;
        document.cookie = "summarizer=0" + brDom;
    }

    if (host.includes('startpage.com')) {
        const spDom = "; domain=.startpage.com" + common;
        document.cookie = "preferences=connect_to_serverEEEdefaultN1Ndate_timeEEEusN1Ndisable_family_filterEEEmoderateN1Ndisable_open_in_new_windowEEE0N1Nenable_post_methodEEE1N1Nenable_proxy_safety_suggestEEE1N1Nenable_stay_controlEEE0N1Ninstant_answersEEE0N1Nlang_homepageEEEs/device/enN1NlanguageEEEenglishN1Nlanguage_uiEEEenglishN1Nnum_of_resultsEEE10N1Nsearch_results_regionEEEallN1NsuggestionsEEE1N1Ntrending_searchesEEE0N1Nwt_unitEEEfahrenheit" + spDom;
    }

    if (host.includes('ecosia.org')) {
        const ecDom = "; domain=.ecosia.org" + common;
        document.cookie = "ECAB=6" + ecDom;
        document.cookie = "ECAIO=false" + ecDom;
        document.cookie = "ECPP=GOOGLE" + ecDom;
    }

    if (host.includes('qwant.com')) {
        const qwDom = "; domain=.qwant.com" + common;
        document.cookie = "hc=0" + qwDom;
        document.cookie = "hide_push_extension_notification=true" + qwDom;
        document.cookie = "hti=0" + qwDom;
    }

    if (host.includes('en.wikipedia.org')) {
        const wkDom = "; domain=.en.wikipedia.org" + common;
        document.cookie = "enwikimwclientpreferences=vector-feature-appearance-pinned-clientpref-0%2Cvector-feature-toc-pinned-clientpref-0%2Cskin-theme-clientpref-night%2Cvector-feature-limited-width-clientpref-1%2Cvector-feature-custom-font-size-clientpref-1" + wkDom;
    }

    if (host.includes('britannica.com')) {
        const ebDom = '; domain=.britannica.com' + common;
        document.cookie = 'usprivacy=1YYY' + ebDom;
    }
})();