import pandas as pd
from matplotlib import pyplot as plt
from pathlib import Path

NN_DIR = Path(__file__).resolve().parent
DATA_PATH = Path(NN_DIR, "data", "swiss_job_offers.csv")
VISUALISATION_PATH = Path(NN_DIR, "visualisation")

col_names = {
    "Diploma": "Diploma",
    "MinYearsExperience": "Minimum Years of Experience",
    "Role": "Role",
    "Contract": "Contract Type",
    "Industry": "Industry",
    "CitySize": "City Size",
    "Canton": "Canton",
    "Perks": "Perks",
    "CompanySize": "Company Size",
    "Languages": "Languages Required",
    "Holidays": "Number of Holidays",
    "MaternityLeaveWeeks": "Maternity Leave (Weeks)",
    "PaternityLeaveWeeks": "Paternity Leave (Weeks)",
    "WorkloadPercent": "Workload Percentage",
    "SalaryCHF": "Salary in CHF"
}

def save_fig(df, column_name, title, xlabel, ylabel, filename):
    counts = df[column_name].value_counts()
    counts.plot(kind='bar', color='lightblue')
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(VISUALISATION_PATH / filename)
    plt.close()

def save_missing_values_per_column(df):
    missing_values = df.isnull().sum()
    missing_values = missing_values[missing_values > 0]
    missing_values.plot(kind='bar', color='lightcoral')
    plt.title('Missing Values per Column')
    plt.xlabel('Columns')
    plt.ylabel('Number of Missing Values')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(VISUALISATION_PATH / 'missing_values_per_column.png')
    plt.close()

def save_roles(df):
    save_fig(
        df=df,
        column_name='Role',
        title='Distribution of Roles',
        xlabel='Role',
        ylabel='Number of Job Offers',
        filename='roles.png'
    )

def save_contract_types(df):
    save_fig(
        df=df,
        column_name='Contract',
        title='Distribution of Contract Types',
        xlabel='Contract Type',
        ylabel='Number of Job Offers',
        filename='contract_types.png'
    )

def save_industries(df):
    save_fig(
        df=df,
        column_name='Industry',
        title='Distribution of Industries',
        xlabel='Industry',
        ylabel='Number of Job Offers',
        filename='industries.png'
    )

def save_city_sizes(df):
    save_fig(
        df=df,
        column_name='CitySize',
        title='Distribution of City Sizes',
        xlabel='City Size',
        ylabel='Number of Job Offers',
        filename='city_sizes.png'
    )

def save_cantons(df):
    save_fig(
        df=df,
        column_name='Canton',
        title='Distribution of Cantons',
        xlabel='Canton',
        ylabel='Number of Job Offers',
        filename='cantons.png'
    )

def save_perks(df):
    save_fig(
        df=df,
        column_name='Perks',
        title='Distribution of Perks',
        xlabel='Perks',
        ylabel='Number of Job Offers',
        filename='perks.png'
    )

def save_company_sizes(df):
    save_fig(
        df=df,
        column_name='CompanySize',
        title='Distribution of Company Sizes',
        xlabel='Company Size',
        ylabel='Number of Job Offers',
        filename='company_sizes.png'
    )

def save_languages(df):
    save_fig(
        df=df,
        column_name='Languages',
        title='Distribution of Languages Required',
        xlabel='Languages',
        ylabel='Number of Job Offers',
        filename='languages.png'
    )

if __name__ == "__main__":
   
    df = pd.read_csv(DATA_PATH)  
    save_missing_values_per_column(df)
    save_roles(df)
    save_contract_types(df)
    save_industries(df)
    save_city_sizes(df)
    save_cantons(df)
    save_perks(df)
    save_company_sizes(df)
    save_languages(df)


