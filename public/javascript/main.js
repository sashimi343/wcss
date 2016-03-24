$(function () {

// テーブルにソート機能を追加する
$("table.table-sorter").tableSort({
    animation: "none",
    speed: 0
});

////////////////////////////////////////////////////////////////////////////////
//  フォーム送信イベント (半Ajax)
////////////////////////////////////////////////////////////////////////////////

// ログインフォーム
$("#login button").on("click", function () {
    myAjax("#login");
});

// 管理者パスワード変更フォーム
$("#change-password button").on("click", function () {
    myAjax("#change-password");
});

// 作曲者追加フォーム
$("#add-composer button").on("click", function () {
    myAjax("#add-composer");
});

// 作曲者情報編集フォーム
$("#modify-composer button").on("click", function () {
    myAjax("#modify-composer");
});

// コンピ追加フォーム
$("#add-compilation button").on("click", function () {
    myAjax("#add-compilation");
});

// コンピ情報編集フォーム
$("#modify-compilation button").on("click", function () {
    myAjax("#modify-compilation");
});

// 楽曲提出フォーム
$("#submit button").on("click", function () {
    // ローディング画像の表示
    displayLoading("送信中...");

    // アップロード状況表示用コールバック関数
    var callback = function (data) {
        var key = data.key;

        updateProgress(
            key,
            2000,
            "送信中... (%)",
            "楽曲の提出が成功しました\n登録した楽曲情報はユーザページで確認できます",
            "/dashboard"
        );
    };

    myAjax("#submit", location.toString(), callback);
});

// コンピへの参加者追加フォーム
$("#add-participant button").on("click", function () {
    myAjax("#add-participant", location.toString()+"/participations");
});


});
