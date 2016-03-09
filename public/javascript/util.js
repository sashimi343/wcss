/**
 * 各種送信ボタンのAjax処理成功時に呼ばれる関数
 * ユーザに結果のフィードバックを行う
 * @param data 処理結果を記述したJSONデータ
 * @param statusCode HTTPステータスコード
 * @param xhr AjaxのXHRオブジェクト
 */
function ajaxSuccessCallback (data, statusCode, xhr) {
    alert(data.message);
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
