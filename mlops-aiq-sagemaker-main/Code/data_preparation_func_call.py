import data_preparation_func as data_preparation_func
import upload_train

# data_preparation_func.split_pdf(r"C:\Users\kkhairnar\comprehend-testing\New folder", r"C:\Users\kkhairnar\comprehend-testing\new")
# pdf_path = input("Enter pdf folder path:")
# output_path = input("Enter destination folder path:")
# data_preparation_func.split_pdf(pdf_path, output_path)

# # data_preparation_func.upload_pdf_to_s3("split pdf file/", 'vstest-py')
# pdf_folder = input("Enter pdf folder path end with slash(/): ")
# bucket = input("Enter bucket name: ")
# data_preparation_func.upload_pdf_to_s3(pdf_folder, bucket)

# # data_preparation_func.adr("vstest-py", "csvfile.csv")
# adr = input("Enter Data Bucket Name to extract: ")
# adr1 = input("Enter output file name with extension(.csv): ")
# data_preparation_func.adr(adr, adr1)

# data_preparation_func.file_merge(r'C:\Users\kkhairnar\pyfunc\csvfile.csv', r'C:\Users\kkhairnar\pyfunc\csvfile1.csv')
path1 = input("enter path of output file: ")
path2 = input("enter path to store merged file with name: ")
data_preparation_func.file_merge(path1, path2)

# '''========================================== End ========================================================================'''

# # upload_train.upload_data('prod10-train.tar.gz', 'vstest-py', 'prod10-train.tar.gz')
# upload_data1 = input("Enter Zip file path: ")
# upload_data2 = input("Enter Bucket name to store train dataset: ")
# upload_data3 = input("Enter new name of Zip file with extension(.tar.gz): ")
# upload_train.upload_data(upload_data1, upload_data2, upload_data3)

# # upload_train.extract_train_data('vstest-py', 'prod10-train.tar.gz')
# bucket_name = input("Enter bucket name: ")
# zip_file = input("Enter uploaded Zip file name: ")
# upload_train.extract_train_data(bucket_name, zip_file)

# # upload_train.dataset("prod10-train/train_dataset.csv", '100')
# data_path = input("Enter extracted train data path: ")
# maxitemperclass = input("Enter Maximum item count per class: ")
# upload_train.dataset(data_path, maxitemperclass)

# upload_train.item_per_class(r'prod10-train/train_dataset.csv',"100")
# train_csv_path = input("Enter Train csv path with extension(.csv): ")



# upload_train.dataset_item("prod10-train/train_dataset.csv", 100)
# upload_train.class_mapping("prod10-train/train_dataset.csv",
# "{1:'Borrower_Certification_And_Authorization',2:'Borrower_Consent_To_Use_Of_Tax_Return_Information',3:'Equal_Credit_Opportunity_Act_Notice',4:'First_Payment_Letter',5:'Flood_Hazard_Notice',6:'IRS_4506',7:'Patriot_Act_Disclosure',8:'UCDP_Submission_Summary_Report',9:'Written_List_Of_Service_Providers',10:'Loan_Closing_Advisor_Feedback_Certificate'}",
# "train11111-data.csv", "comprehend-experiment-344021507737")
# upload_train.build_classifier("arn:aws:iam::344021507737:role/ComprehendExperimentBucketAccessRole",
# "arn:aws:iam::344021507737:policy/ComprehendExperimentDataAccessRolePolicy",
# "arn:aws:s3:::comprehend-experiment-344021507737",
# "adr-clssifier-prod12",
# "train11111-data.csv")
# upload_train.train_classifier("arn:aws:comprehend:us-east-1:344021507737:document-classifier/adr-clssifier-prod12")

# # upload_train.ConfusionMatrix(r'C:\Users\kkhairnar\comprehend-testing\prod10-train\output\confusion_matrix.json', '(10,10)')
# cm_jsonpath = input("Enter confusion matrix json file path: ")
# figsize = input("Enter size of Confusion Matrix in the format (int,int): ")
# upload_train.ConfusionMatrix(cm_jsonpath, figsize)
