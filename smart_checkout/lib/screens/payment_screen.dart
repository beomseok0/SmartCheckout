import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int originalPrice = 3000;
  int couponDiscount = 0;
  int pointsToUse = 0;
  int availablePoints = 5000;
  bool usePoints = false;
  String selectedCoupon = '쿠폰 선택';
  String selectedPaymentMethod = '결제 수단 선택';

  List<Map<String, dynamic>> availableCoupons = [
    {'name': '3,000원 할인 쿠폰', 'discount': 3000},
    {'name': '1,000원 할인 쿠폰', 'discount': 1000},
    {'name': '10% 할인 쿠폰', 'discount': 300},
  ];

  List<String> paymentMethods = [
    '신용카드',
    '체크카드',
    '카카오페이',
    '네이버페이',
    '삼성페이',
    '현금'
  ];

  int get finalPrice {
    int price = originalPrice - couponDiscount;
    if (usePoints) {
      price -= pointsToUse;
    }
    return price < 0 ? 0 : price;
  }

  void _showCouponPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CupertinoColors.systemBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '쿠폰 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: availableCoupons.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CupertinoListTile(
                      title: Text('쿠폰 사용 안함'),
                      onTap: () {
                        setState(() {
                          selectedCoupon = '쿠폰 선택';
                          couponDiscount = 0;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }
                  final coupon = availableCoupons[index - 1];
                  return CupertinoListTile(
                    title: Text(coupon['name']),
                    subtitle: Text('${coupon['discount']}원 할인'),
                    onTap: () {
                      setState(() {
                        selectedCoupon = coupon['name'];
                        couponDiscount = coupon['discount'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CupertinoColors.systemBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '결제 수단 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return CupertinoListTile(
                    title: Text(method),
                    leading: Icon(_getPaymentIcon(method)),
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case '신용카드':
      case '체크카드':
        return CupertinoIcons.creditcard;
      case '카카오페이':
      case '네이버페이':
      case '삼성페이':
        return CupertinoIcons.device_phone_portrait;
      case '현금':
        return CupertinoIcons.money_dollar;
      default:
        return CupertinoIcons.creditcard;
    }
  }

  void _processPayment() {
    if (selectedPaymentMethod == '결제 수단 선택') {
      _showAlert('결제 수단을 선택해주세요.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text('결제 진행'),
        content: Column(
          children: [
            SizedBox(height: 10),
            CupertinoActivityIndicator(),
            SizedBox(height: 10),
            Text('결제를 처리하고 있습니다...'),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      _showPaymentSuccess();
    });
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('결제 완료'),
        content: Text('결제가 성공적으로 완료되었습니다.'),
        actions: [
          CupertinoDialogAction(
            child: Text('확인'),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('알림'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemBackground,
        foregroundColor: CupertinoColors.label,
        title: Text(
          '결제하기',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: CupertinoColors.label,
            size: 28,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // 제품 정보
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.cube_box_fill,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '베지밀',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '수량: 1개',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₩${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // 쿠폰 섹션
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '할인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showCouponPicker,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CupertinoColors.systemGrey4,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedCoupon,
                                  style: TextStyle(
                                    color: selectedCoupon == '쿠폰 선택'
                                        ? CupertinoColors.placeholderText
                                        : CupertinoColors.label,
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (couponDiscount > 0) ...[
                          SizedBox(height: 8),
                          Text(
                            '-₩${couponDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 할인',
                            style: TextStyle(
                              color: CupertinoColors.systemRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // 포인트 섹션
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '포인트 사용',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '보유 ${availablePoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}P',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              value: usePoints,
                              onChanged: (value) {
                                setState(() {
                                  usePoints = value;
                                  if (value) {
                                    pointsToUse =
                                        (originalPrice - couponDiscount)
                                            .clamp(0, availablePoints);
                                  } else {
                                    pointsToUse = 0;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (usePoints) ...[
                          SizedBox(height: 12),
                          Text(
                            '사용할 포인트',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CupertinoColors.systemGrey4,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${pointsToUse.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}P',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // 결제 금액 요약
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '결제 금액',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '상품 금액',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            Text(
                              '₩${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (couponDiscount > 0) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '쿠폰 할인',
                                style: TextStyle(
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                              Text(
                                '-₩${couponDiscount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: TextStyle(
                                  color: CupertinoColors.systemRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (usePoints && pointsToUse > 0) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '포인트 사용',
                                style: TextStyle(
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                              Text(
                                '-₩${pointsToUse.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: TextStyle(
                                  color: CupertinoColors.systemBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '총 결제 금액',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₩${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.systemBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // 결제 수단 선택
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '결제 수단',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showPaymentMethodPicker,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CupertinoColors.systemGrey4,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (selectedPaymentMethod != '결제 수단 선택')
                                      Icon(
                                        _getPaymentIcon(selectedPaymentMethod),
                                        size: 20,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    if (selectedPaymentMethod != '결제 수단 선택')
                                      SizedBox(width: 8),
                                    Text(
                                      selectedPaymentMethod,
                                      style: TextStyle(
                                        color: selectedPaymentMethod ==
                                                '결제 수단 선택'
                                            ? CupertinoColors.placeholderText
                                            : CupertinoColors.label,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 결제 버튼
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              border: Border(
                top: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _processPayment,
                  child: Text(
                    '₩${finalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 결제하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget CupertinoListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    subtitle,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
