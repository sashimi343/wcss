/**
 * フォームに割り当てられたidとリクエスト先URLをもとにAjaxを行う
 * 成功時、失敗時のコールバック関数はajaxSuccessCallback, ajaxErrorCallback
 * @param id POSTを行うフォームのid ('#'を含む)
 * @param リクエスト先URL (省略時は現在のパス)
 */
function myAjax (id, url) {
    // フォームデータの取得
    var form = $(id).get(0);
    var formData = new FormData(form);

    // POSTリクエスト
    $.ajax({
        url: url || location.toString(),
        type: "POST",
        dataType: "json",
        data: formData,
        processData: false,
        contentType: false,
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback
    });
}

/**
 * 各種送信ボタンのAjax処理成功時に呼ばれる関数
 * ユーザに結果のフィードバックを行う
 * @param data 処理結果を記述したJSONデータ
 * @param statusCode HTTPステータスコード
 * @param xhr AjaxのXHRオブジェクト
 */
function ajaxSuccessCallback (data, statusCode, xhr) {
    if(data.message)    alert(data.message);
    location.href = data.redirect || location.toString();
}

/**
 * 各種送信ボタンのAjax処理失敗時に呼ばれる関数
 * ユーザに通信失敗の旨を通知する
 * @param xhr AjaxのXHRオブジェクト
 * @param textStatus エラー内容を示すテキスト
 * @param e 例外オブジェクト
 */
function ajaxErrorCallback (xhr, textStatus, e) {
    alert("An error was occurred\nPlease try again later");
}

/**
 * ローディング画像を表示する
 * @param msg 画像と共に表示するメッセージ (省略可)
 */
function displayLoading (msg) {
    // 画面表示メッセージ
    var message = "";
 
    // 引数が空の場合は画像のみ
    if(msg != "") {
        message = "<div class='loadingMsg'>" + msg + "</div>";
    }
    // ローディング画像が表示されていない場合のみ表示
    if($("#loading").size() == 0) {
        $("body").append("<div id='loading'>" + message + "</div>");
    } 
}
 
/**
 * ローディング画像を消す
 */
function removeLoading () {
    $("#loading").remove();
}
