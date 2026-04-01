import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkWrapper extends StatelessWidget {
  final Widget child;

  const NetworkWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityResult>>(
      // التحقق الأولي من الشبكة عند بدء التشغيل
      future: Connectivity().checkConnectivity(),
      builder: (context, initialSnapshot) {
        return StreamBuilder<List<ConnectivityResult>>(
          // مراقبة تغيرات الشبكة لحظياً
          stream: Connectivity().onConnectivityChanged,
          initialData: initialSnapshot.data,
          builder: (context, snapshot) {
            final connectivityResults = snapshot.data;

            // منطق فحص الأوفلاين
            bool isOffline = connectivityResults == null ||
                connectivityResults.contains(ConnectivityResult.none);

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                // منع تغيير حجم المحتوى عند ظهور لوحة المفاتيح لضمان استقرار الـ Stack
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    // الطبقة الأساسية: تطبيقك (الموسوعة الشاملة)
                    // تبقى نشطة دائماً للوصول للكاش والبيانات المحلية
                    child,

                    // الطبقة العلوية: شريط تنبيه الأوفلاين
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                      top: isOffline ? 0 : -100, // يختفي للأعلى عند توفر النت
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.95),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text(
                              "أنت تعمل في وضع الأوفلاين (تصفح كتبك المحملة)",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}