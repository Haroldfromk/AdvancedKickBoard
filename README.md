# Table of Contents
1. [Description](#description)
2. [Timeline](#timeline)
3. [Demo](#demo)
4. [Features](#features)
5. [Requirements](#requirements)
6. [Stacks](#stacks)
7. [ProjectStructure](#projectStructure)
8. [Developer](#developer)

# Bean Mobility Korea

킥보드 렌탈이 가능한 Bean App!

## Description

주변에 대여 가능한 킥보드를 확인하고, 대여까지! 간편한 결제 방식과 그 외에 여러 기능들을 경험해보세요!

## Timeline

자세한 내용은 [Repository](https://github.com/Haroldfromk/bean-scooter-pjt) 참고 부탁드립니다.

## Demo
<p float="left">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/4328ddbc-937e-4d0b-b486-94bc2456d561" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/dc57391b-8139-45b1-9490-d5648d936c26" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/04ccb255-e4c1-421a-9f63-ae2c97625602" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/d83aa43d-ee09-46ac-b334-893e54f77bce" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/1a253df5-752a-4ee1-8235-81f2a2d3b2f4" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/d8a00b9d-3c8d-4f8e-ac0d-396728440321" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/30b3d22e-438f-47dd-afcf-2747f44e3540" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/75054b95-e74b-44d8-917f-a1c51bee3ef1" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/d7a86600-13e5-475d-b0e1-ad79b0c86880" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/cd26f2d3-1c85-4de5-8af2-2ebf15f44701" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/22fda91e-76f3-449e-b54c-09f77ce2a9b4" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/42eee60f-fde2-48d7-aa5e-ba55094ec40c" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/9b0063e2-2dba-4280-9ac8-e5b3bbdde1c3" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/79cbf6a3-10bf-4350-9244-fbf7dfddcbc9" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/01fd8e86-79bd-4bf1-9243-cfac5c930419" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/ba6ece38-ef79-4b76-b668-f4a03e596cae" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/5ed6ee28-732b-4fc8-980f-b99511352d81" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/987eafa9-b99a-4b75-96de-af06ef8d0108" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/36af0180-e963-4c4a-b4bd-ee12e99bd4d3" width="200" height="430">
<img src="https://github.com/moremirim/bean-scooter-pjt/assets/160707647/a5293592-0476-4868-81c0-c2ea4f64363a" width="200" height="430">
</p>

## Features

추가기능 구현을 위한 Repository 입니다. 구현 후 작성 예정입니다.

## Requirements
- App requires **iOS 17.4 or above**

## Stacks
- **Environment**

    <img src="https://img.shields.io/badge/-Xcode-147EFB?style=flat&logo=xcode&logoColor=white"/> <img src="https://img.shields.io/badge/-git-F05032?style=flat&logo=git&logoColor=white"/>

- **Language**

    <img src="https://img.shields.io/badge/-swift-F05138?style=flat&logo=swift&logoColor=white"/> 

- **API**

    <img src="https://img.shields.io/badge/-Kakao-FFCD00?style=flat&logo=Kakao&logoColor=white"/>

- **Communication**

    <img src="https://img.shields.io/badge/-Slack-4A154B?style=flat&logo=Slack&logoColor=white"/> <img src="https://img.shields.io/badge/-Notion-000000?style=flat&logo=Notion&logoColor=white"/> <img src="https://img.shields.io/badge/-Figma-F24E1E?style=flat&logo=Figma&logoColor=white"/>

## Project Structure

```markdown
Bean
├── Singleton
│   ├── RecordSingleton
│   └── SavedPinSingleton
│
├── Service
│   ├── CoordGenerator
│   └── MapManager
│
├── Model
│   ├── AccountInfo
│   ├── AcountModel
│   ├── CouponModel
│   ├── GuideModel
│   ├── MapModel
│   ├── ProfileModel
│   ├── RecordModel
│   └── PinModel.xcdatamodeld
│
├── View
│   ├── CouponCollectionViewCell
│   ├── GuideTableViewCell
│   ├── ProfileTableViewCell
│   ├── RecordTableViewCell
│   ├── ScooterManagerTableViewCell
│   ├── LaunchScreen.storyboard
│   └── Main.storyboard
│
├── Controller
│   ├── CouponViewController
│   ├── EditProfileViewController
│   ├── GuideViewController
│   ├── InviteFriendsViewController
│   ├── LaunchViewController
│   ├── MapViewController
│   ├── ModalViewController
│   ├── ProfileViewController
│   ├── RecordTableViewController
│   ├── ScooterManageViewController
│   ├── SignInViewController
│   ├── SignupViewController
│   ├── TabbarViewController
│   └── PayViewController
│
├── Assets
└ 
```

## Developer
*  **송동익** ([Haroldfromk](https://github.com/haroldfromk))
