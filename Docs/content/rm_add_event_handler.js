document.write('\
\
<div id="rm_add_event_handler"><div class="prochdr1">rm_add_event_handler</div><div class="prochdr2"> - Add event handler</div></div>\
<pre class="procsig">\
&lt;&lt;pointer<br>\
map   pointer        value<br>\
hproc pointer(*proc) value<br>\
usrd  pointer        value options(*nopass)<br>\
</pre>\
<p>\
Add event handler <code>hproc</code> to the list of event handlers registered \
for <code>map</code>, and return <code>map</code>.<br>\
Events are fired when key/item pairs are inserted into and removed \
from <code>map</code>. When an event is fired then all event handlers added to \
the map are called in the reversed order they were added (last one \
first).<br>\
Procedure <code>hproc</code> must have the following signature:\
</p>\
<pre class="procsig">\
  rtn type: int(10)<br>\
  par. 1  : event int(10) value<br>\
       2  : map   pointer value<br>\
       3  : key   pointer value<br>\
       4  : item  pointer value<br>\
       5  : usrd  pointer value<br>\
</pre>\
<p>\
Parameter <code>event</code> is <code>1</code> when the "inserted" event has been triggered \
just after a key/item pair has been inserted, or <code>2</code> when the "removed" \
event has been triggered just before a key/item pair is removed.<br>\
Parameters <code>key</code> and <code>item</code> is the key/item pair that has been inserted, \
or is about to be removed. In the latter case the key and value will be \
removed immediately after all the event handlers have been called. When \
the key and value are removed they\'re disposed (unless they\'re manually \
disposed maps).<br>\
Parameter <code>map</code> is the map where the event was fired, <code>usrd</code> is the \
user data that was optionally passed with parameter <code>usrd</code> when adding \
the event handler with <a href="#rm_add_event_handler"><code>rm_add_event_handler</code></a> (or <code>*null</code> if not passed).<br>\
The handler\'s return value is ignored.<br>\
If the same handler is added multiple times it will be called as many \
times as it was added.<br>\
Event handlers are removed with procedure <a href="#rm_remove_event_handler"><code>rm_remove_event_handler</code></a>.<br>\
If a map is disposed then no event handlers will be called. Use <a href="#rm_rmva"><code>rm_rmva</code></a> \
first to remove all key/value pairs and fire events, then dispose the map.\
</p>\
\
');