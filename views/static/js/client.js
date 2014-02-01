function init() {
	setupClickableTemplates();
    if($('li.active').length == 0) {
        $("#templateUL li").first().addClass("active");
    }
    $('#templateFormDiv')
        .on('submit', 'form', function(e) {
            e.preventDefault();
            if(e.target.classList.contains('edit')) {
                saveCurrentTemplate(e.target.action, start=false, stop=false, function(result) {
                        var menuItem = $('#templateUL li[data-index='+result['id']+']');
                        var label = menuItem.find('span.label');
                        menuItem.empty();
                        if(label) {
                            menuItem.append(label)
                                    .append('<span class="delete pull-right">&times;</span>');
                        }
                        menuItem.append(result['newTitle']);
                });
                $('#success')
                    .text('Saved Message.')
                    .fadeIn(function() {
                        setTimeout(function() {
                            $('#success').fadeOut();
                        }, 800);
                    });
            }
            //if we are creating a new template
            else {
                saveCurrentTemplate(e.target.action, start=false, stop=false, function(result) {
                    var newMenuItem = '<li data-index="'+result.id+'">'+
                                            '<span class="delete pull-right">&times;</span>'+
                                            result.newTitle+
                                        '</li>';
                    $('#templateUL li[data-index=new]').before(newMenuItem);
                });
                $('#success')
                    .text('Created New Message.')
                    .fadeIn(function() {
                        setTimeout(function() {
                            $('#success').fadeOut();
                        }, 800);
                    });
            }

            return false;
        })
        .on('click', 'input.start', function(e) {
            e.preventDefault();
            saveCurrentTemplate(e.target.parentNode.parentNode.action, start=true, stop=false, function(result) {
                if(result.status == 'ok') {
                    $('#templateUL li span.selected').remove();
                    $(".active").append('<span class="label label-warning selected">Active</span>');
                    $("#startStop").addClass("btn-danger").removeClass("btn-success").removeClass("start").addClass("stop").val("Stop Auto-Reply");
                    $('#success')
                        .text('Activated Auto-Reply on your phone!')
                        .fadeIn(function() {
                            setTimeout(function() {
                                $('#success').fadeOut();
                            }, 800);
                        });
                }
            });
            return false;
        })
        .on('click', 'input.stop', function(e) {
            e.preventDefault();
            saveCurrentTemplate(e.target.parentNode.parentNode.action, start=false, stop=true, function(result) {
                if(result.status == 'ok') {
                    $("span").remove()
                    $("#startStop").removeClass("btn-danger").addClass("btn-success").addClass("start").removeClass("stop").val("Start Auto-Reply!");
                    var menuItem = $('#templateUL li[data-index='+result.id+']');
                    menuItem.empty().text(result.newTitle);
                    $('#error')
                        .text('Deactivated Auto-Reply on your phone.')
                        .fadeIn(function() {
                            setTimeout(function() {
                                $('#error').fadeOut();
                            }, 800);
                        });
                }
            });
            return false;
        });
}

function sendSuccess(str) {
    alert(str);
}


function setupClickableTemplates() {
    $("#nav").on('click', 'li', function(e) {
        var index = $(this)[0].dataset.index;
        if(e.target.classList.contains('delete')) {
            if($('#nav li').length > 2) {
                $.ajax({
                    url: '/templates/'+index,
                    type: 'DELETE',
                    success: function() {
                        $(e.currentTarget).remove();
                        $('#nav li').first().click();
                        window.location.href = window.location.href;
                    }
                });
            }
            return false;
        }
		$('#nav li.active').removeClass('active');
		$(this).addClass('active');

        if (index == 'new') {
            $("#templateFormDiv").find('form')
                .removeClass('edit').addClass('new')
                .attr('action','/templates/new')
                .end().find('input[type=text],textarea').val('')
                .end().find('input[type=button]').hide();
        }
        else {
            templateAjax(index, function(data) {
                $("#templateFormDiv").html(data);
                window.CURRENT_ID = index;
            });
        }
    });
}

function templateAjax(id, onSuccess) {
    $.ajax({
    	type: "get",
    	url: 'templates/' + String(id),
    	success: onSuccess
    });
}

function saveCurrentTemplate(url, start, stop, cb) {
    if (!cb) {
        cb = function() { return; };
    }
    var title = $('#templateTitle').val(),
         text = $('#templateText').val();
    var data = {
        title: title,
        text: text
    };

    if(start) {
        data['isSelected'] = true;
        text = "{start} " + text;
    }
    else if(stop) {
        data['isSelected'] = false;
        text = "{stop}";
    }
    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        contentType: 'application/x-www-form-urlencoded',
        success: function(result) {
            if(start || stop) {
                $.ajax({
                    type: "POST",
                    data: { text: text },
                    url: '/send_sms',
                    success: function() {
                        return;
                    },
                    contentType: 'application/x-www-form-urlencoded'
                });
            }
            cb(JSON.parse(result));
        }
    });
}



$(document).ready(function() {
	init();
});



