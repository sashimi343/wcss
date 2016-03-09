$(function () {

// 作曲者情報の編集処理
$("#modify-composer button").on("click", function () {
    // フォームパラメータの取得
    var registration_id = $("#modify-composer [name=registration_id]").val();
    var password = $("#modify-composer [name=password]").val();
    var password_confirmation = $("#modify-composer [name=password_confirmation]").val();
    var contact = $("#modify-composer [name=contact]").val();

    $.ajax({
        url: location.toString(),
        type: "POST",
        dataType: "json",
        data: {
            registration_id: registration_id,
            password: password,
            password_confirmation: password_confirmation,
            contact: contact
        },
        success: ajaxSuccessCallback,
        error: ajaxErrorCallback
    });
});

});
