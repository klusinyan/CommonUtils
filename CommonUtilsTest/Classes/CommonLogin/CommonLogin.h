//  Created by Karen Lusinyan on 11/09/14.

typedef NS_ENUM(NSInteger, CommonLoginCellType) {
    CommonLoginCellTypeUnknownl=0,
    CommonLoginCellTypeTextInput,
    CommonLoginCellTypeButton,
};

@interface CommonLoginCellInfo : NSObject

@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, strong) NSString *value;
@property (readwrite, nonatomic, getter=isMandatory) BOOL mandatory;
@property (readwrite, nonatomic, assign) CommonLoginCellType *cellType;

@end

@protocol CommonLoginDelegate;
@protocol CommonLoginDataSource;

@interface CommonLogin : UITableViewController

typedef void(^LoginCompletionHandler)(BOOL success);

@property (readwrite, nonatomic, getter=isLogged) BOOL logged;

@property (readwrite, nonatomic, assign) id<CommonLoginDelegate> delegate;

@property (readwrite, nonatomic, assign) id<CommonLoginDataSource> dataSource;

@end

@protocol CommonLoginDataSource <NSObject>

- (NSInteger)numberOfRows;

- (CommonLoginCellInfo *)commonLogin:(CommonLogin *)commonLogin cellAttributesForRowAtIndex:(NSInteger)index;

@end

@protocol CommonLoginDelegate <NSObject>

- (void)commonLogin:(CommonLogin *)commonLogin button:(id)button didSelectAtIndex:(NSInteger)index;

//- (void)loginWithCreadentials:(NSDictionary *)credentials;

//- (void)logout;

@end
