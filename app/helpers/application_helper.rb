module ApplicationHelper
  def sort_link(label, column)
    direction = (params[:sort] == column && params[:direction] == "asc") ? "desc" : "asc"
    indicator = ""
    if params[:sort] == column || (params[:sort].blank? && column == "name")
      indicator = (params[:direction] == "desc" || (params[:sort].blank? && column == "name" && params[:direction] != "desc")) ? " \u25B2" : " \u25BC"
      if params[:sort] == column && params[:direction] == "desc"
        indicator = " \u25BC"
      elsif params[:sort] == column && params[:direction] == "asc"
        indicator = " \u25B2"
      else
        indicator = " \u25B2"
      end
    end
    link_to "#{label}#{indicator}".html_safe, teams_path(sort: column, direction: direction, search: params[:search], page: 1), class: "sort-link"
  end
end
