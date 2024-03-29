﻿var Utils = {
    isDeviceMobile: function () {
        // device detection
        if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) ||
            /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0, 4)))
            return true;

        return false;
    },

    getParameterByName: function (name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    sortChildrenByAttribute: function (parent, childSelector, attribute) {
        var items = parent.children(childSelector).sort(function (a, b) {
            var vA = $(a).attr(attribute);
            var vB = $(b).attr(attribute);
            return (vA < vB) ? -1 : (vA > vB) ? 1 : 0;
        });

        parent.append(items);
    },

    firstletterUpper: function (data) {
        return data.substr(0, 1).toUpperCase() + data.substr(1);
    },

    globalSettings: function () {
        if (typeof $.fn.dataTable !== "undefined") {
            $.extend(true, $.fn.dataTable.defaults, {
                processing: true,
                serverSide: true,
                dom: "<'row'<'col-sm-4'lB><'col-sm-4'p><'col-sm-4'f>>" +
                    "<'row'<'col-sm-12 table-responsive'tr>>" +
                    "<'row'<'col-sm-4'i><'col-sm-4'p>>",
                buttons: ["reload"],
                language: Constants.DATA_TABLE_LANGUAGE
            });

            $.fn.dataTable.ext.errMode = 'none';
            $.fn.dataTable.ext.buttons.reload = {
                text: '<i class="fa fa-refresh"></i>',
                action: function (e, dt) {
                    dt.ajax.reload(null, true);
                }
            };
        }

        if (typeof window.Pace !== "undefined")
            $(document).ajaxStart(function () {
                Pace.restart();
            });

        /**
         * String.prototype.replaceAll() polyfill
         * https://gomakethings.com/how-to-replace-a-section-of-a-string-with-another-one-with-vanilla-js/
         * @author Chris Ferdinandi
         * @license MIT
         */
        if (!String.prototype.replaceAll) {
            String.prototype.replaceAll = function (str, newStr) {

                // If a regex pattern
                if (Object.prototype.toString.call(str).toLowerCase() === '[object regexp]') {
                    return this.replace(str, newStr);
                }

                // If a string
                return this.replace(new RegExp(str, 'g'), newStr);

            };
        }
    },

    /**
     *
     * @param {Array} arr
     * @param {string} key
     */
    sortArrayByAttribute: function (arr, key) {
        arr.sort(function (a, b) {
            if (typeof a === "string" || typeof b === "string")
                return (a[key] + "").localeCompare(b[key] + "");

            return a[key] - b[key];
        });
    },

    stripHMTLTag: function (str) {
        return str.replace(/</g, "&lt;").replace(/>/g, "&gt;");
    },

    unStripHMTLTag: function (str) {
        return str.replace(/&lt;/g, "<").replace(/&gt;/g, ">");
    },

    onSubmitBtnClicked: function (e) {
        var target = $(e.currentTarget);
        target.append("<i class='fa fa-spinner fa-pulse' style='margin-left:5px'></i>");
        target.attr("disabled", true);
    },

    setSubmitBtn: function () {
        $('.submit-btn').unbind("click", Utils.onSubmitBtnClicked.bind(this));
        $('.submit-btn').click(Utils.onSubmitBtnClicked.bind(this));
    },

    resetSubmitBtn: function () {
        $(".submit-btn").attr("disabled", false);
        $(".submit-btn").find("i").remove();
    },

    showMessage: function (text, onHide) {
        if ($("#message").length > 0) {
            $('.modal').modal('hide');

            if (typeof onHide === "function") {
                $("#message").unbind("hidden.bs.modal");
                $("#message").on("hidden.bs.modal", onHide);
            }

            $("#messageText").html(text);
            $("#message").modal("show");
        } else
            throw new Error("No error modal found.");
    },

    showError: function (errorText, onHide, hideOtherModals) {
        var hideOtherModals = typeof hideOtherModals === "undefined" ? true : hideOtherModals;

        if ($("#errorDialog").length > 0 && !($("#errorDialog").data('bs.modal') || { isShown: false }).isShown) {
            if (hideOtherModals)
                $('.modal').modal('hide');

            $("#errorDialog").unbind("hidden.bs.modal");
            $("#errorDialog").on("hidden.bs.modal", function () {
                Utils.resetSubmitBtn();
                if (typeof onHide === "function") onHide();
            });

            $("#errorDialog").find('#errorMsg').html(errorText);
            $("#errorDialog").modal({ backdrop: 'static' });
        }
    },

    showLoading: function (text, onHide) {
        if ($("#modal_loading").length > 0) {
            $('.modal').modal('hide');

            $("#modal_loading").unbind("hidden.bs.modal");
            $("#modal_loading").on("hidden.bs.modal", function () {
                Utils.resetSubmitBtn();
                if (typeof onHide === "function") onHide();
            });

            $("#modal_loading").find('#loadingText').html(text);
            $("#modal_loading").modal({ drop: 'static', backdrop: 'static', keyboard: false });
        }
    },

    showConfirm: function (question, onConfirm, askPwd) {
        askPwd = typeof askPwd === "undefined" ? true : askPwd;

        if ($("#confirmWithPassword").length > 0) {
            $('.modal').modal('hide');
            Utils.resetSubmitBtn();
            $("#confirmWithPassword").find("#confirm_text").html(question);
            $("#confirmWithPassword").find("#confirm_password").unbind("keypress");
            $("#confirmWithPassword").find("#confirm_button").unbind("click");
            $("#confirmWithPassword").find("input#confirm_password").val("");

            if (!askPwd)
                $("#confirmWithPassword").find(".form-group").hide();

            $("#confirmWithPassword").find("#confirm_button").click(function () {
                if (askPwd && $("#confirmWithPassword").find("input#confirm_password").val() == "" ||
                    /^\s+$/.test($("#confirmWithPassword").find("input#confirm_password").val())) {
                    Utils.showError("Non &egrave; stata inserita nessuna password.");
                    return; //function will not keep on executing
                }

                if (askPwd) {
                    var dati = { confirmpassword: $("#confirmWithPassword").find("input#confirm_password").val() };

                    Utils.requestData(
                        Constants.API_CHECK_PWD,
                        "POST",
                        dati,
                        onConfirm
                    );
                } else
                    onConfirm();
            });

            $("#confirmWithPassword").find("input#confirm_password").keypress(function (event) {
                if (event.which == 13) {
                    event.preventDefault();
                    $("#confirmWithPassword").find("#confirm_button").click();
                }
            });

            $("#confirmWithPassword").modal({
                backdrop: "static"
            });

            $("#confirmWithPassword").find("input#confirm_password").focus();
        } else
            throw new Error("No confirm modal found.");
    },

    requestData: function (url, method, data, success, failure, onSuccessHide, onFailureHide) {
        $.ajax({
            url: url,
            data: data,
            method: method,
            xhrFields: {
                withCredentials: true
            },
            success: function (data) {
                if (data.status === "ok" && typeof success === "string")
                    Utils.showMessage(success, onSuccessHide);
                else if (data.status === "ok" && typeof success === "function")
                    success(data);
                else if (data.status === "error" && (data.type === "loginError" || data.type === "grantsError") && typeof window.AdminLTEManager !== "undefined") {
                    Utils.showError(data.message, AdminLTEManager.logout);
                    throw new Error(data.message);
                } else if (data.status === "error" && data.type === "pgLoginError") {
                    Utils.showError(data.message, Utils.redirectTo.bind(this, Constants.MAIN_PAGE));
                    throw new Error(data.message);
                } else if (data.status === "error" && typeof failure === "string")
                    Utils.showError(failure, onFailureHide);
                else if (data.status === "error" && typeof failure === "function")
                    failure(data);
                else if (data.status === "error" && (typeof failure === "undefined" || failure === null))
                    Utils.showError(data.message.replace("\n", "<br>"), onFailureHide);
            }.bind(this),
            error: function (jqXHR, textStatus, errorThrown) {
                var real_error = textStatus + "<br>" + errorThrown;

                if (textStatus === "parsererror")
                    real_error = jqXHR.responseText.replace(/^([\S\s]*?)\{"[\S\s]*/i, "$1");

                real_error = real_error.replace("\n", "<br>");

                if (data.status === "error" && (data.type === "loginError" || data.type === "grantsError"))
                    Utils.showError(failure, AdminLTEManager.logout);
                else if (data.status === "error" && typeof failure !== "function")
                    Utils.showError(real_error, onFailureHide);
                else if (data.status === "error" && typeof failure === "function")
                    failure({ message: real_error, type: "genericError" });
            }
        });
    },

    controllaPermessiUtente: function (user_info, permessi, tutti) {
        tutti = typeof tutti === "undefined" ? true : tutti;

        for (var p in permessi) {
            if (tutti && user_info.permessi.indexOf(permessi[p]) === -1)
                return false;
            else if (!tutti && user_info.permessi.indexOf(permessi[p]) !== -1)
                return true;
        }

        if (tutti)
            return true;
        else
            return false;
    },

    controllaPermessiPg: function (pg_info, permessi, tutti) {
        tutti = typeof tutti === "undefined" ? true : tutti;

        for (var p in permessi) {
            if (tutti && pg_info.permessi.indexOf(permessi[p]) === -1)
                return false;
            else if (!tutti && pg_info.permessi.indexOf(permessi[p]) !== -1)
                return true;
        }

        if (tutti)
            return true;
        else
            return false;
    },

    rimuoviPermessi: function (info, permessi) {
        var rimuovi_da = info.permessi;

        for (var p in permessi) {
            var i = rimuovi_da.indexOf(permessi[p]);
            if (i !== -1)
                rimuovi_da.splice(i, 1);
        }
    },

    pad: function (num, size) {
        var n = parseInt(num, 10),
            minus = n < 0 ? "-" : "",
            s = "000" + Math.abs(n);
        return minus + s.substr(s.length - size);
    },

    clearLocalStorage: function () {
        window.localStorage.clear();
    },

    redirectTo: function (url) {
        window.location.href = url;
    },

    reloadPage: function () {
        window.location.reload();
    },

    setCookie: function (cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        document.cookie = cname + "=" + cvalue + "; " + expires;
    },

    deleteCookie: function (cname) {
        document.cookie = cname + "=" + "; expires=Thu, 01 Jan 1970 00:00:00 UTC";
    },

    getCookie: function (cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') c = c.substring(1);
            if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
        }
        return "";
    },

    rimuoviElemDaArrayMultidimensione: function (arr, chiave, valore) {
        for (var a in arr) {
            if (arr[a][chiave] === valore) {
                arr.splice(a, 1);
                break;
            }
        }
    },

    isLink: function (str) {
        var urlPatt = new RegExp(
            "^" +
            // protocol identifier
            "(?:(?:https?|ftp)://)" +
            // user:pass authentication
            "(?:\\S+(?::\\S*)?@)?" +
            "(?:" +
            // IP address exclusion
            // private & local networks
            "(?!(?:10|127)(?:\\.\\d{1,3}){3})" +
            "(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})" +
            "(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})" +
            // IP address dotted notation octets
            // excludes loopback network 0.0.0.0
            // excludes reserved space >= 224.0.0.0
            // excludes network & broacast addresses
            // (first & last IP address of each class)
            "(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])" +
            "(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}" +
            "(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))" +
            "|" +
            // host name
            "(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)" +
            // domain name
            "(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*" +
            // TLD identifier
            "(?:\\.(?:[a-z\\u00a1-\\uffff]{2,}))" +
            ")" +
            // port number
            "(?::\\d{2,5})?" +
            // resource path
            "(?:/\\S*)?" +
            "$", "i");

        return urlPatt.test(str);
    },

    controllaAccessoPagina: function (section) {
        Utils.requestData(
            Constants.API_GET_ACESS,
            "POST",
            "section=" + section + "&" + window.location.search.substr(1),
            null,
            null,
            null,
            AdminLTEManager.logout
        );
    },

    controllaCF: function (cf) {
        var pattern = /^[a-zA-Z]{6}[0-9]{2}[a-zA-Z][0-9]{2}[a-zA-Z][0-9]{3}[a-zA-Z]$/;

        return pattern.test(cf);
    },

    controllaMail: function (mail) {
        var pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        return pattern.test(mail);
    },

    soloSpazi: function (stringa) {
        var pattern = /^\s+$/;

        return pattern.test(stringa);
    },

    getJQueryObj: function (obj) {
        var jobj = {};

        if (typeof obj === "string")
            jobj = $("#" + obj);
        else if (obj instanceof $)
            jobj = obj;
        else if (obj instanceof HTMLElement)
            jobj = $(obj);

        return jobj;
    },

    trasformaInArray: function (obj) {
        return Array.prototype.slice.call(obj);
    },

    indexOfArrayOfObjects: function (arr, key, value) {
        for (var a in arr) {
            if (arr[a][key] === value)
                return parseInt(a, 10);
        }

        return -1;
    },

    dynamicColor: function () {
        var r = Math.floor(Math.random() * 255);
        var g = Math.floor(Math.random() * 255);
        var b = Math.floor(Math.random() * 255);
        return "rgb(" + r + "," + g + "," + b + ")";
    },

    arraySum: function (arr) {
        return arr.reduce(function (prev, curr) {
            return prev + curr;
        }, 0);
    },

    msToHMS: function (ms) {
        // 1- Convert to seconds:
        var seconds = ms / 1000;
        // 2- Extract hours:
        var hours = parseInt(seconds / 3600); // 3,600 seconds in 1 hour
        seconds = seconds % 3600; // seconds remaining after extracting hours
        // 3- Extract minutes:
        var minutes = parseInt(seconds / 60); // 60 seconds in 1 minute
        // 4- Keep only seconds not extracted to minutes:
        seconds = parseInt(seconds % 60, 10);
        return Utils.pad(hours, 2) + " ore, " + Utils.pad(minutes, 2) + " minuti, " + Utils.pad(seconds, 2) + " secondi";
    },

    hexToRGBa: function (hex, opacity) {
        hex = hex.replace(/^#?([0-9A-F]{3,6})/i, "$1");

        var ha = hex.split(""),
            r = g = b = 0,
            ret = typeof opacity === 'number' ? 'rgba({0},' + opacity + ')' : 'rgb({0})';

        if (ha.length === 3) {
            r = parseInt(ha[0] + ha[0], 16);
            g = parseInt(ha[1] + ha[1], 16);
            b = parseInt(ha[2] + ha[2], 16);
        } else if (ha.length === 6) {
            r = parseInt(ha[0] + ha[1], 16);
            g = parseInt(ha[2] + ha[3], 16);
            b = parseInt(ha[4] + ha[5], 16);
        } else
            throw new Error("You must enter either a 3 or 6 ciphers hexadecimal number.");

        return ret.replace(/\{0}/g, r + "," + g + "," + b);
    },

    getFormData: function (form, avoidEmpty) {
        var avoidEmpty = typeof avoidEmpty == "undefined" ? false : avoidEmpty,
            form_edit = form.clone(),
            unindexed_array = [], //form.serializeArray(),
            indexed_array = {};

        //form_edit.find( "input[type='checkbox']" ).remove();
        unindexed_array = form.serializeArray();

        $.map(unindexed_array, function (n) {
            if (avoidEmpty && n['value'] === "")
                return false;

            if (!indexed_array[n['name']])
                indexed_array[n['name']] = n['value'];
            else if (indexed_array[n['name']] && !(indexed_array[n['name']] instanceof Array)) {
                indexed_array[n['name']] = [indexed_array[n['name']]];
                indexed_array[n['name']].push(n['value']);
            } else if (indexed_array[n['name']] && indexed_array[n['name']] instanceof Array)
                indexed_array[n['name']].push(n['value']);
        });

        form.find("input[type='checkbox']").each(function () {
            var name = $(this).attr("name").replace(/\[\]$/, ""),
                value = $(this).is(":checked") ? 1 : 0;

            if (indexed_array[name] && !(indexed_array[name] instanceof Array) && typeof indexed_array[name] !== "string") {
                indexed_array[name] = [indexed_array[name]];
                indexed_array[name].push(value);
            } else if (indexed_array[name] && indexed_array[name] instanceof Array)
                indexed_array[name].push(value);
            else
                indexed_array[name] = value;
        });

        form.find("select[multiple]").each(function () {
            if ($(this).find("option:selected").size() === 0)
                indexed_array[$(this).attr("name")] = "";
            else
                indexed_array[$(this).attr("name")] =
                    Array.prototype.slice.call($(this).find("option:selected")).map(function (el) { return el.value; });
        });

        return indexed_array;
    },

    mischia: function (a) {
        var j, x, i;
        for (i = a.length - 1; i > 0; i--) {
            j = Math.floor(Math.random() * (i + 1));
            x = a[i];
            a[i] = a[j];
            a[j] = x;
        }
        return a;
    },

    generaCodiceAntiFrode: function () {
        var vip = "AEIOU",
            nonvip = "BCDFGHJKLMNPQRSTVWXYZ123456789",
            lung = 20,
            num_vip = 9,
            num_blocchi = 4,
            lung_blocco = lung / num_blocchi,
            codice = [],
            codice_finale = [];

        for (var i = 0; i < num_vip; i++) {
            var ran = Math.floor(Math.random() * vip.length);
            codice.push(vip.charAt(ran));
        }

        for (var i = 0; i < lung - num_vip; i++) {
            var ran = Math.floor(Math.random() * nonvip.length);
            codice.push(nonvip.charAt(ran));
        }

        codice = Utils.mischia(codice);

        for (var i = 0, j = codice.length; i < j; i += lung_blocco) {
            codice_finale.push(codice.slice(i, i + lung_blocco).join(""));
        }

        return codice_finale.join("-");
    },

    resetForm: function (form) {
        form.trigger("reset");
        form.find(".iCheck").each(function () {
            $(this).iCheck("uncheck");
        });
    },
};

$(function () {
    Utils.globalSettings();
});