	function debug(aMsg) { setTimeout(function() { throw new Error("[debug] " + aMsg); }, 0); }

	var timer;
	var updating = false;
	var missed = 0;

	function msgTimerClear() {
		window.clearTimeout(timer);
		timer = undefined;
	}

	function msgTimerSet() {
		msgTimerClear();
		updating = false;
		var interval;
		if ( missed > 0 ) { interval = 25 } else { interval = 2000 };
		missed = 0;
		timer = window.setTimeout( "update_messages()", interval )
	}

	function get_last_message () {

		var last_message = $('messages').firstChild;

		/* the first elem will be a text node */
		while( last_message.nodeType != 1 )
			last_message = last_message.nextSibling;

		return last_message;

	}

	function message_num ( msg_div ) {
		return msg_div.id.match('[0-9]+$');
	}

	function update_messages () {
		msgTimerClear();
		if (!updating) {
			updating = true;

			var last_message = get_last_message();

			new Ajax.Updater( last_message, '/messages/from/' + message_num( last_message ), {
				asynchronous: true,
				insertion:    Insertion.Before,
				onComplete:   msgTimerSet,
				onFailure:    function() { alert("error! couldn't contact server") }
			});
		}
	}

	function submit_form(form) {
		msgTimerClear();
		if (updating) {	
			missed++;
			new Ajax.Request('/messages/send', {
				parameters:   Form.serialize(form),
				asynchronous: true
			});
		} else {
			updating = true;
			var last_message = get_last_message();
			new Ajax.Updater(last_message, '/messages/send/' + message_num( last_message ), {
				insertion:    Insertion.Before,
				parameters:   Form.serialize(form),
				asynchronous: true,
				onComplete:   msgTimerSet,
				onFailure:    function() { alert("error! couldn't contact server") }
			});
		}

		form.reset();
	}

