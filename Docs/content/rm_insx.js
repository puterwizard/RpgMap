document.write('\
\
<div id="rm_insx"><div class="prochdr1">rm_insx</div><div class="prochdr2"> - Insert key/item pairs, exclusive</div></div>\
<pre class="proclongnm">rm_insert_excl</pre>\
<pre class="procsig">\
&lt;&lt;pointer<br>\
map  pointer value<br>\
k001 pointer value options(*nopass)<br>\
i001 pointer value options(*nopass)<br>\
...<br>\
k100 pointer value options(*nopass)<br>\
i100 pointer value options(*nopass)<br>\
</pre>\
<p>\
Like <a href="#rm_ins"><code>rm_ins</code></a>, but before a key/item pair is inserted all key/item \
pairs with a key equal to the key to be inserted are removed first \
(i.e. they\'re replaced).\
</p>\
\
');