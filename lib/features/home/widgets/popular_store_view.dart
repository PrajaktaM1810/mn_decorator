import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class PopularStoreView extends StatelessWidget {
  final bool isPopular;
  final bool isFeatured;
  const PopularStoreView({super.key, required this.isPopular, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = isFeatured ? storeController.featuredStoreList : isPopular ? storeController.popularStoreList
          : storeController.latestStoreList;

      return (storeList != null && storeList.isEmpty) ? const SizedBox() : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, isPopular ? 2 : 15, 10, 10),
            child: TitleWidget(
              title: isFeatured ? 'featured_stores'.tr : isPopular ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                  ? 'popular_restaurants'.tr : 'popular_stores'.tr : '${'new_on'.tr} ${AppConstants.appName}',
              onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute(isFeatured ? 'featured' : isPopular ? 'popular' : 'latest')),
            ),
          ),

          SizedBox(
            height: 160,
            child: storeList != null ? ListView.builder(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              itemCount: storeList.length > 10 ? 10 : storeList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: 5),
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.15), blurRadius: 7, spreadRadius: 0)],
                    ),
                    child: CustomInkWell(
                      onTap: () {
                        if(isFeatured && Get.find<SplashController>().moduleList != null) {
                          for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                            if(module.id == storeList[index].moduleId) {
                              Get.find<SplashController>().setModule(module);
                              break;
                            }
                          }
                        }
                        Get.toNamed(
                          RouteHelper.getStoreRoute(id: storeList[index].id, page: isFeatured ? 'module' : 'store'),
                          arguments: StoreScreen(store: storeList[index], fromModule: isFeatured),
                        );
                      },
                      radius: Dimensions.radiusSmall,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Stack(children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                            child: CustomImage(
                              image: '${storeList[index].coverPhotoFullUrl}',
                              height: 90, width: 200, fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: storeController.getDiscount(storeList[index]),
                            discountType: storeController.getDiscountType(storeList[index]),
                            freeDelivery: storeList[index].freeDelivery,
                          ),
                          storeController.isOpenNow(storeList[index]) ? const SizedBox() : const NotAvailableWidget(isStore: true),
                          Positioned(
                            top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                            child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                              bool isWished = favouriteController.wishStoreIdList.contains(storeList[index].id);
                              return InkWell(
                                onTap: () {
                                  if(AuthHelper.isLoggedIn()) {
                                    isWished ? favouriteController.removeFromFavouriteList(storeList[index].id, true)
                                        : favouriteController.addToFavouriteList(null, storeList[index].id, true);
                                  }else {
                                    showCustomSnackBar('you_are_not_logged_in'.tr);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Icon(
                                    isWished ? Icons.favorite : Icons.favorite_border,  size: 15,
                                    color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ]),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                storeList[index].userName ?? '',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              // Text(
                              //   storeList[index].address ?? '',
                              //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                              //   maxLines: 1, overflow: TextOverflow.ellipsis,
                              // ),
                              // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              RatingBar(
                                rating: storeList[index].avgRating,
                                ratingCount: storeList[index].ratingCount,
                                size: 12,
                              ),
                            ]),
                          ),
                        ),

                      ]),
                    ),
                  ),
                );
              },
            ) : PopularStoreShimmer(storeController: storeController),
          ),
        ],
      );
    });
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      itemCount: 10,
      itemBuilder: (context, index){
        return Container(
          height: 150,
          width: 200,
          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)]
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 90, width: 200,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                    color: Colors.grey[300]
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 10, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}

