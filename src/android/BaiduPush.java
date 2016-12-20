package org.apache.cordova.baidu;

import java.util.ArrayList;
import java.util.List;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import com.baidu.android.pushservice.PushConstants;
import com.baidu.android.pushservice.PushManager;
import com.baidu.android.pushservice.PushSettings;

/**
 * 百度云推送插件
 * 
 * @author NCIT
 *
 */
public class BaiduPush extends CordovaPlugin {
    /** LOG TAG */
    private static final String LOG_TAG = BaiduPush.class.getSimpleName();

	/** JS回调接口对象 */
    public static CallbackContext pushCallbackContext = null;
  
    /**
     * 插件初始化
     */
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	LOG.d(LOG_TAG, "BaiduPush#initialize");

        super.initialize(cordova, webView);
    }

    /**
     * 插件主入口
     */
    @Override
    public boolean execute(String action, final JSONArray args, CallbackContext callbackContext) throws JSONException {
    	LOG.d(LOG_TAG, "BaiduPush#execute");

    	boolean ret = false;
    	
        if ("startWork".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;

            final String apiKey = args.getString(0);

            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try{
                        LOG.d(LOG_TAG, "PushManager#startWork");
                        PushSettings.enableDebugMode(cordova.getActivity().getApplicationContext(), true);
                        PushManager.startWork(cordova.getActivity().getApplicationContext(),
                        PushConstants.LOGIN_TYPE_API_KEY, apiKey);
                    }catch(Exception e){
                        e.printStackTrace();
                    }
                }
            });
            ret =  true;
        } else if ("registerChannel".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;

            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try{
                        LOG.d(LOG_TAG, "PushManager#registerChannel");
                        //PushManager.startWork(cordova.getActivity().getApplicationContext());
                    }catch(Exception e){
                        e.printStackTrace();
                    }
                }
            });
            ret = true;
        } else if ("setApplicationIconBadgeNumber".equalsIgnoreCase(action)) {

        } else if ("getApplicationIconBadgeNumber".equalsIgnoreCase(action)) {

        } else if ("clearAllNotifications".equalsIgnoreCase(action)) {

        } else if ("hasPermission".equalsIgnoreCase(action)) {

        } else if ("stopWork".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;

            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                	LOG.d(LOG_TAG, "PushManager#stopWork");
                    PushManager.stopWork(cordova.getActivity().getApplicationContext());
                }
            });
            ret =  true;
        } else if ("resumeWork".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;

            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try{
                        LOG.d(LOG_TAG, "PushManager#resumeWork");
                        PushManager.resumeWork(cordova.getActivity().getApplicationContext());
                    }catch(Exception e){
                        e.printStackTrace();
                    }
                }
            });
            ret = true;
        } else if ("setTags".equalsIgnoreCase(action)) {
            pushCallbackContext = callbackContext;

            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                	LOG.d(LOG_TAG, "PushManager#setTags");
                	
                	List<String> tags = null;
                	if (args != null && args.length() > 0) {
                		int len = args.length();
                		tags = new ArrayList<String>(len);
                		
                		for (int inx = 0; inx < len; inx++) {
                			try {
								tags.add(args.getString(inx));
							} catch (JSONException e) {
								LOG.e(LOG_TAG, e.getMessage(), e);
							}
                		}

                		PushManager.setTags(cordova.getActivity().getApplicationContext(), tags);
                	}
                	
                }
            });
            ret = true;
        } else if ("delTags".equalsIgnoreCase(action)) {
        	pushCallbackContext = callbackContext;

            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                	LOG.d(LOG_TAG, "PushManager#delTags");
                	
                	List<String> tags = null;
                	if (args != null && args.length() > 0) {
                		int len = args.length();
                		tags = new ArrayList<String>(len);
                		
                		for (int inx = 0; inx < len; inx++) {
                			try {
								tags.add(args.getString(inx));
							} catch (JSONException e) {
								LOG.e(LOG_TAG, e.getMessage(), e);
							}
                		}

                		PushManager.delTags(cordova.getActivity().getApplicationContext(), tags);
                	}
                	
                }
            });
            ret = true;
        }

        return ret;
    }
}
