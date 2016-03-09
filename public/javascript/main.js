$(function () {

// ログイン処理
$("#login button").on("click", function () {
    // フォームパラメータの取得
    var registration_id = $("#login [name=registration_id]").val();
    var password = $("#login [name=password]").val();

    $.ajax({
        url: location.toString(),
        type: "POST",
        dataType: "json",
        data: {
            registration_id: registration_id,
            password: password,
        },
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback
    });
});

// 作曲者情報の編集処理
$("#modify-composer button").on("click", function () {
    // フォームパラメータの取得
    var registration_id = $("#modify-composer [name=registration_id]").val();
    var password = $("#modify-composer [name=password]").val();
    var password_confirmation = $("#modify-composer [name=password_confirmation]").val();
    var name = $("#modify-composer [name=name]").val();
    var contact = $("#modify-composer [name=contact]").val();

    $.ajax({
        url: location.toString(),
        type: "POST",
        dataType: "json",
        data: {
            registration_id: registration_id,
            password: password,
            password_confirmation: password_confirmation,
            name: name,
            contact: contact
        },
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback
    });
});

// 楽曲提出処理
$("#submit button").on("click", function () {
    // フォームパラメータの取得・設定
    var fd = new FormData();
    if($("#submit [name=wav_file]").val() !== "") {
        fd.append("wav_file", $("#submit [name=wav_file]").prop("files")[0]);
    }
    fd.append("song_title", $("#submit [name=song_title]").val());
    fd.append("artist", $("#submit [name=artist]").val());
    fd.append("comment", $("#submit [name=comment]").val());

    // ローディング画像の表示
    displayLoading("Submitting...");

    $.ajax({
        url: location.toString(),
        type: "POST",
        dataType: "json",
        data: fd,
        processData: false,
        contentType: false,
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback,
        complete: removeLoading
    });
});

// 作曲者情報の編集処理
$("#change-password button").on("click", function () {
    // フォームパラメータの取得
    var current_password = $("#change-password [name=current_password]").val();
    var password = $("#change-password [name=password]").val();
    var password_confirmation = $("#change-password [name=password_confirmation]").val();

    $.ajax({
        url: location.toString(),
        type: "POST",
        dataType: "json",
        data: {
            current_password: current_password,
            password: password,
            password_confirmation: password_confirmation,
        },
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback
    });
});

// 作曲者の追加処理
$("#add-composer button").on("click", function () {
    // フォームパラメータの取得
    var registration_id = $("#add-composer [name=registration_id]").val();
    var password = $("#add-composer [name=password]").val();
    var password_confirmation = $("#add-composer [name=password_confirmation]").val();
    var name = $("#add-composer [name=name]").val();
    var contact = $("#add-composer [name=contact]").val();

    $.ajax({
        url: location.toString(),
        type: "POST",
        dataType: "json",
        data: {
            registration_id: registration_id,
            password: password,
            password_confirmation: password_confirmation,
            name: name,
            contact: contact
        },
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback
    });
});

});
