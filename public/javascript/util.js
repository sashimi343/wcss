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

/**
 * 期限までの残り時間をカウントダウンするタイマーを作成する
 * http://qiita.com/stm3/items/45ee16aca2972abf7c7d 参照
 * @param deadline_utc 締め切り日時 (UTC)
 */
function countDown (deadline_utc) {
    var startDateTime = new Date();
    var endDateTime = new Date(deadline_utc);
    var left = endDateTime - startDateTime;
    var a_day = 24 * 60 * 60 * 1000;

    // 締め切りを過ぎている場合、カウントダウンを終了する
    if(left < 0) {
        $("#deadline-timer").text("You are late for the deadline!");
        return;
    }

    // 期限から現在までの『残時間の日の部分』
    var d = Math.floor(left / a_day) 

    // 期限から現在までの『残時間の時間の部分』
    var h = Math.floor((left % a_day) / (60 * 60 * 1000)) 

    // 残時間を秒で割って残分数を出す。
    // 残分数を60で割ることで、残時間の「時」の余りとして、『残時間の分の部分』を出す
    var m = Math.floor((left % a_day) / (60 * 1000)) % 60 

    // 残時間をミリ秒で割って、残秒数を出す。
    // 残秒数を60で割った余りとして、「秒」の余りとしての残「ミリ秒」を出す。
    // 更にそれを60で割った余りとして、「分」で割った余りとしての『残時間の秒の部分』を出す
    var s = Math.floor((left % a_day) / 1000) % 60 % 60 

    $("#deadline-timer").text(d + "days " + h + "hours " + m + "minutes " + s + "seconds");
    setTimeout(countDown, 1000, deadline_utc);
}
