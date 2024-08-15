window.addEventListener('message', function(event) {
    if (event.data.type === 'show') {
        $('#userImg').attr('src', event.data.img);
        $('#userName').text(event.data.name);
        $('#container').removeClass('hidden').fadeIn(500, function() {
            setTimeout(function() {
                $('#container').fadeOut(500, function() {
                    $(this).addClass('hidden');
                });
            }, 5000);
        });
    }
});
