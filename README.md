CDNControl UI
===========
CDNControl UI is the web interface to Etsy's CDNControl tool, a rubygem which provides an interface to Dyn's GSLB service. It's used by Etsy to control the balance of traffic between our CDN providers, and also to enable or disable individual CDNs.

Installation
------------

Follow the below steps to get CDNControl UI up and running:

- Clone the CDNControl UI repository to somewhere on your server - here we'll assume /opt/cdncontrol_ui
- cd into the directory where you cloned CDNControl UI
- run the command ```bundle install```
- Make sure you've got your correctly configured CDNControl configuration file in ```/usr/local/etc/cdncontrol.conf``` - please see ```https://github.com/etsy/cdncontrol/blob/master/README.md``` for details
- Run the command ```thin start```
- If everything's working correctly, you should see output similar to the following:

```
>> Using rack adapter
>> Thin web server (v1.5.0 codename Knife)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:3000, CTRL+C to stop
```

- You're all done! CDNControl UI should now be running at ```http://yourserver:3000``` - you can now start tweaking your CDNs!!



CDNControl UI Usage
================

- On the CDNControl UI interface, the ```targets``` you specified in your CDNControl configuration file are arranges as tabs along the top of the page. Click on a tab to select that target.
- The current provider state and balances for that target will then be loaded.
- You can change provider states and balance values using the dropdowns and sliders provided.
- Once you're happy with your changes, click "Apply Settings"
- You will then be presented with a confirmation dialogue listing the changes to be applied. Click "cancel" if you do not want to continue, otherwise click "Save".
- A progress dialogue will then appear while changes are being saved.
- Once changes have been saved, a summary dialogue will appear with "Success" or "Failure" beside each item as applicable.
- After clicking "Close" on this dialogue, the target will be reloaded to display the new balance / provider status