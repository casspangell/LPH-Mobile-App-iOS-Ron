//
//  DBUtils.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 15/12/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//
import CoreData

class DBUtils {
    
    static func insertCategoryList(categoryList: [CategoryVo]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSOverwriteMergePolicy
        for category in categoryList {
            let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.category, in: managedContext)!
            let coreDataNews = NSManagedObject(entity: entity, insertInto: managedContext)
            coreDataNews.setValue(category.id, forKeyPath: CoreDataProperty.categoryId)
            coreDataNews.setValue(category.name, forKeyPath: CoreDataProperty.categoryTitle)
            coreDataNews.setValue(category.imageUrl, forKeyPath: CoreDataProperty.categoryImageUrl)
            coreDataNews.setValue(category.totalPostCount, forKeyPath: CoreDataProperty.categoryPostCount)
            coreDataNews.setValue(category.unreadPostCount, forKeyPath: CoreDataProperty.categoryUnreadCount)
            coreDataNews.setValue(category.favouritePostCount, forKeyPath: CoreDataProperty.categoryFavouriteCount)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            managedContext.reset()
        }
    }
    
    static func updateCategory(category: CategoryVo) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.category)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.categoryId + " == %@", category.id)
        let fetchedList = try? managedContext.fetch(fetchRequest)
        if (fetchedList?.count)! > 0 {
            let fetchedCategory = fetchedList![0] as NSManagedObject
            fetchedCategory.setValue(category.favouritePostCount, forKey: CoreDataProperty.categoryFavouriteCount)
            fetchedCategory.setValue(category.unreadPostCount, forKey: CoreDataProperty.categoryUnreadCount)
            fetchedCategory.setValue(category.totalPostCount, forKey: CoreDataProperty.categoryPostCount)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    static func fetchCategory(categoryId: String) -> CategoryVo? {
        var categoryVo: CategoryVo?
        var categoryList = [CategoryVo]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.category)
        fetchRequest.predicate = NSPredicate(format: CoreDataProperty.categoryId + " == %@", categoryId)
        let fetchedList = try? managedContext.fetch(fetchRequest) as! [Category]
        if (fetchedList?.count)! > 0 {
            categoryVo = CategoryVo()
            categoryVo?.id = fetchedList![0].categoryId!
            categoryVo?.name = fetchedList![0].title!
            categoryVo?.imageUrl = fetchedList![0].imageUrl!
            categoryVo?.totalPostCount = fetchedList![0].newsCount!
            categoryVo?.unreadPostCount = fetchedList![0].unreadNewsCount!
            categoryVo?.favouritePostCount = fetchedList![0].favoritesCount!
        }
        return categoryVo
    }
    
    static func fetchCategoryList() -> [CategoryVo] {
        var categoryList = [CategoryVo]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntity.category)
        let fetchedList = try? managedContext.fetch(fetchRequest) as! [Category]
        for category in fetchedList! {
            var categoryVo = CategoryVo()
            categoryVo.id = category.categoryId!
            categoryVo.name = category.title!
            categoryVo.imageUrl = category.imageUrl!
            categoryVo.totalPostCount = category.newsCount!
            categoryVo.unreadPostCount = category.unreadNewsCount!
            categoryVo.favouritePostCount = category.favoritesCount!
            categoryList.append(categoryVo)
        }
        return categoryList
    }
    
    static func fetchNewsList(type: NewsType) -> [NewsVo] {
        var newsList: [NewsVo]
        switch type {
        case .recent:
            newsList = getNewsRecent()
            break
            
        case .favourite:
            newsList = getNewsFavourite()
            break
            
        case .category:
            newsList = getNewsCategory()
            break
        }
        
        return newsList
    }
    
    private static func getNewsRecent() -> [NewsVo] {
        var newsRecentList = [NewsVo]()
        let fetchedList = getCoreDataFetchedList(entityName: CoreDataEntity.newsRecent) as! [NewsRecent]
        for news in fetchedList {
            var newsVo = NewsVo()
            newsVo.id = news.newsId!
            newsVo.title = news.newsTitle!
            newsVo.description = news.newsDescription!
            newsVo.detailsUrl = news.newsDetailsUrl!
            newsVo.imageUrl = news.newsImageUrl!
            newsVo.timeStamp = news.newsTimeStamp!
            newsVo.date = news.newsDate!
            newsVo.isFavourite = news.isFavorite
            newsVo.isRead = news.isRead
            newsRecentList.append(newsVo)
        }
        return newsRecentList
    }
    
    private static func getNewsFavourite() -> [NewsVo] {
        var newsRecentList = [NewsVo]()
        let fetchedList = getCoreDataFetchedList(entityName: CoreDataEntity.newsFavourite) as! [NewsFavourite]
        for news in fetchedList {
            var newsVo = NewsVo()
            newsVo.id = news.newsId!
            newsVo.title = news.newsTitle!
            newsVo.description = news.newsDescription!
            newsVo.detailsUrl = news.newsDetailsUrl!
            newsVo.imageUrl = news.newsImageUrl!
            newsVo.timeStamp = news.newsTimeStamp!
            newsVo.date = news.newsDate!
            newsVo.isFavourite = news.isFavorite
            newsVo.isRead = news.isRead
            newsRecentList.append(newsVo)
        }
        return newsRecentList
    }
    
    private static func getNewsCategory() -> [NewsVo] {
        var newsCategoryList = [NewsVo]()
        let fetchedList = getCoreDataFetchedList(entityName: CoreDataEntity.newsCategory) as! [NewsCategory]
        for news in fetchedList {
            var newsVo = NewsVo()
            newsVo.id = news.newsId!
            newsVo.title = news.newsTitle!
            newsVo.description = news.newsDescription!
            newsVo.detailsUrl = news.newsDetailsUrl!
            newsVo.imageUrl = news.newsImageUrl!
            newsVo.timeStamp = news.newsTimeStamp!
            newsVo.date = news.newsDate!
            newsVo.isFavourite = news.isFavorite
            newsVo.isRead = news.isRead
            newsCategoryList.append(newsVo)
        }
        return newsCategoryList
    }
    
    private static func getCoreDataFetchedList(entityName: String) -> [Any] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataProperty.newsTimeStamp, ascending: false)]
        let fetchedList = try? managedContext.fetch(fetchRequest)
        return fetchedList!
    }
    
    static func insertNewsList(newsList: [NewsVo], type: NewsType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        var newsEntityName: String
        switch type {
        case .recent:
            newsEntityName = CoreDataEntity.newsRecent
        case .favourite:
            newsEntityName = CoreDataEntity.newsFavourite
        case .category:
            newsEntityName = CoreDataEntity.newsCategory
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSOverwriteMergePolicy
        for news in newsList {
            let entity = NSEntityDescription.entity(forEntityName: newsEntityName, in: managedContext)!
            let coreDataNews = NSManagedObject(entity: entity, insertInto: managedContext)
            coreDataNews.setValue(news.id, forKeyPath: CoreDataProperty.newsId)
            coreDataNews.setValue(news.title, forKeyPath: CoreDataProperty.newsTitle)
            coreDataNews.setValue(news.description, forKeyPath: CoreDataProperty.newsDescription)
            coreDataNews.setValue(news.detailsUrl, forKeyPath: CoreDataProperty.newsDetailsUrl)
            coreDataNews.setValue(news.imageUrl, forKeyPath: CoreDataProperty.newsImageUrl)
            coreDataNews.setValue(news.isRead, forKeyPath: CoreDataProperty.isRead)
            coreDataNews.setValue(news.isFavourite, forKeyPath: CoreDataProperty.isFavorite)
            coreDataNews.setValue(news.timeStamp, forKeyPath: CoreDataProperty.newsTimeStamp)
            coreDataNews.setValue(news.date, forKeyPath: CoreDataProperty.newsDate)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            managedContext.reset()
        }
    }
    
    static func deleteNews(newsId: String?, type: NewsType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        var entityName: String
        switch type {
        case .recent:
            entityName = CoreDataEntity.newsRecent
            break
            
        case .favourite:
            entityName = CoreDataEntity.newsFavourite
            break
            
        case .category:
            entityName = CoreDataEntity.newsCategory
            break
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        if newsId != nil {
            fetchRequest.predicate = NSPredicate(format: CoreDataProperty.newsId + " == %@", newsId!)
        }
        let fetchedList = try? managedContext.fetch(fetchRequest)
        for singleItem in fetchedList! {
            managedContext.delete(singleItem as NSManagedObject)
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

enum NewsType {
    case recent
    case favourite
    case category
}
