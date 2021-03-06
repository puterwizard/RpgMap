document.write('\
\
<div id="rm_n_"><div class="prochdr1">rm_n_</div><div class="prochdr2"> - Convert an indicator to an RPG indicator value</div></div>\
<pre class="procsig">\
&lt;&lt;ind<br>\
value   pointer value<br>\
default ind     value options(*nopass)<br>\
</pre>\
<p>\
Return an RPG indicator from <code>value</code>, which must be an indicator.<br>\
If <code>value</code> is <code>*null</code> then return <code>*off</code>, or <code>default</code> \
when passed. If <code>value</code> is not compatible escape message RM00011 (value not \
compatible) is sent.<br>\
</p>\
\
');